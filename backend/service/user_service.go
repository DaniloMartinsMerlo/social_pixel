package service

import (
	"time"

	"github.com/google/uuid"
	"github.com/socialpixel/backend/domain"
)

type userService struct {
	repo domain.UserRepository
}

func NewUserService(repo domain.UserRepository) domain.UserService {
	return &userService{repo: repo}
}

func (s *userService) Register(req domain.RegisterUserRequest) (*domain.User, error) {
	user := &domain.User{
		ID:        uuid.NewString(),
		Username:  req.Username,
		Email:     req.Email,
		Password:  req.Password,
		CreatedAt: time.Now(),
	}
	if err := s.repo.Create(user); err != nil {
		return nil, err
	}
	return user, nil
}

func (s *userService) Login(req domain.LoginRequest) (*domain.User, error) {
	user, err := s.repo.FindByEmail(req.Email)
	if err != nil {
		return nil, err
	}
	if user.Password != req.Password {
		return nil, domain.ErrInvalidCredentials
	}
	return user, nil
}

func (s *userService) GetProfile(id string) (*domain.User, error) {
	return s.repo.FindByID(id)
}

func (s *userService) UpdateProfile(id string, req domain.UpdateProfileRequest) (*domain.User, error) {
	user, err := s.repo.FindByID(id)
	if err != nil {
		return nil, err
	}
	if req.Username != "" {
		user.Username = req.Username
	}
	if req.AvatarURL != "" {
		user.AvatarURL = req.AvatarURL
	}
	if err := s.repo.Update(user); err != nil {
		return nil, err
	}
	return user, nil
}
