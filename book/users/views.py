from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes,authentication_classes
from rest_framework.response import Response
from rest_framework.authtoken.serializers import AuthTokenSerializer
from rest_framework import generics, permissions
from .serializers import RegisterSerializer, UserRentalSerializer,UserSerializer, BookSerializer
from .models import Book, Rental
from django.contrib.auth.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth import logout
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.decorators import login_required
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework import status
from rest_framework.views import APIView
from django.contrib.auth import authenticate
from decimal import Decimal
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework import serializers
from .models import Book




class LoginView(APIView):
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        user = authenticate(username=username, password=password)
        if user is not None:
            return Response({
                'user_data': UserSerializer(user).data,
                'access_token': 'your_access_token_here',
                'refresh_token': 'your_refresh_token_here',
            }, status=status.HTTP_200_OK)
        else:
            return Response({'detail': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)


def serialize_user(user):
    return {
        "username": user.username,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name
    }

class BookList(APIView):
    def post(self, request):
        serializer = BookSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = '__all__'

@api_view(['POST'])
def login(request):
    serializer = AuthTokenSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)
    user = serializer.validated_data['user']
    refresh = RefreshToken.for_user(user)
    return Response({
        'user_data': serialize_user(user),
        'access_token': str(refresh.access_token),
        'refresh_token': str(refresh)
    })



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    try:
        refresh_token = request.data['refresh_token']
        token = RefreshToken(refresh_token)
        token.blacklist()
        return Response({'message': 'Logout successful'})
    except Exception:
        return Response({'message': 'Failed to logout'}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def register(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid(raise_exception=True):
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response({
            "user_info": serialize_user(user),
            "access_token": str(refresh.access_token),
            "refresh_token": str(refresh)
        })


@api_view(['GET'])
def get_user(request):
    user = request.user
    if user.is_authenticated:
        return Response({
            'user_data': serialize_user(user)
        })
    return Response({})

class BookCreateView(generics.CreateAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer


class UserListView(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = []

class BookListView(generics.ListAPIView):
    queryset = Book.objects.all()
    serializer_class = BookSerializer

class UserBookRentalsListView(generics.ListAPIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, user_id):
        # Filter out rentals that have been returned
        rentals = Rental.objects.filter(user__id=user_id, returned=False)
        books = [rental.book for rental in rentals]
        serializer = BookSerializer(books, many=True)
        return Response(serializer.data)


@api_view(['POST'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def rent_book(request, book_id):
    try:
        book = Book.objects.get(id=book_id)
    except Book.DoesNotExist:
        return Response({"error": "Book not found."}, status=status.HTTP_404_NOT_FOUND)
    
    if not book.available:
        return Response({"error": "Book is already rented."}, status=status.HTTP_400_BAD_REQUEST)
    
    user_rentals = Rental.objects.filter(user=request.user, returned=False)
    if user_rentals.count() >= 3:
        return Response({"error": "User has reached the rental limit."}, status=status.HTTP_400_BAD_REQUEST)
    
    rental_days = request.data.get("rental_days", 1)
    try:
        rental_days = int(rental_days)
    except ValueError:
        return Response({"error": "Invalid rental days value."}, status=status.HTTP_400_BAD_REQUEST)
    
    rental_date = timezone.now()
    return_date = rental_date + timezone.timedelta(days=rental_days)
    rental = Rental(book=book, user=request.user, rental_date=rental_date, return_date=return_date, returned=False)
    rental.save()
    
    book.available = False
    book.save()
    
    rental_price = rental_days * book.price
    return Response({"success": f"Book {book.title} rented successfully.", "rental_price": str(rental_price)}, status=status.HTTP_200_OK)


@api_view(['PUT'])
@authentication_classes([JWTAuthentication])
@permission_classes([IsAuthenticated])
def return_book(request, book_id):
    try:
        rental = Rental.objects.get(book_id=book_id, user=request.user, returned=False)
    except Rental.DoesNotExist:
        return Response({"error": "Rental not found."}, status=404)

    rental.returned = True
    rental.return_date = timezone.now()
    rental.save()

    book = rental.book
    book.available = True
    book.save()

    return Response({"success": f"Book {book.title} returned successfully."}, status=200)

    
