package domain

import (
	"errors"
	"time"
)

var (
	ErrUserNotFound       = errors.New("user not found")
	ErrEmailAlreadyInUse  = errors.New("email already in use")
	ErrInvalidCredentials = errors.New("invalid email or password")
)

type User struct {
	ID        string    `json:"id"`
	Username  string    `json:"username"`
	Email     string    `json:"email"`
	Password  string    `json:"-"`
	AvatarURL string    `json:"avatar_url"`
	CreatedAt time.Time `json:"created_at"`
}

type RegisterUserRequest struct {
	Username string `json:"username" binding:"required,min=3,max=50"`
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6,max=100"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6,max=100"`
}

type UpdateProfileRequest struct {
	Username  string `json:"username" binding:"omitempty,min=3,max=50"`
	AvatarURL string `json:"avatar_url"`
}

type UserRepository interface {
	Create(user *User) error
	FindByID(id string) (*User, error)
	FindByEmail(email string) (*User, error)
	Update(user *User) error
}

type UserService interface {
	Register(req RegisterUserRequest) (*User, error)
	Login(req LoginRequest) (*User, error)
	GetProfile(id string) (*User, error)
	UpdateProfile(id string, req UpdateProfileRequest) (*User, error)
}
