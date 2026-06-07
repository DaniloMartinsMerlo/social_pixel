package service

import (
	"time"

	"github.com/google/uuid"
	"github.com/socialpixel/backend/domain"
)

type artworkService struct {
	artworkRepo      domain.ArtworkRepository
	notificationRepo domain.NotificationRepository
}

func NewArtworkService(artworkRepo domain.ArtworkRepository, notificationRepo domain.NotificationRepository,) domain.ArtworkService {
	return &artworkService{
		artworkRepo:      artworkRepo,
		notificationRepo: notificationRepo,
	}
}

func (s *artworkService) Create(userID, title string, width, height int, pixels domain.PixelMap) (*domain.Artwork, error) {
	if !domain.AllowedSizes[width] || !domain.AllowedSizes[height] {
		return nil, domain.ErrInvalidCanvasSize
	}

	now := time.Now()
	a := &domain.Artwork{
		ID:        uuid.NewString(),
		UserID:    userID,
		Title:     title,
		Width:     width,
		Height:    height,
		Pixels:    pixels,
		CreatedAt: now,
		UpdatedAt: now,
	}
	if err := s.artworkRepo.Create(a); err != nil {
		return nil, err
	}
	return a, nil
}

func (s *artworkService) GetByID(artworkID, requesterID string) (*domain.Artwork, error) {
	a, err := s.artworkRepo.FindByID(artworkID)
	if err != nil {
		return nil, err
	}
	a.Liked, _ = s.artworkRepo.IsLiked(artworkID, requesterID)
	a.LikeCount, _ = s.artworkRepo.CountLikes(artworkID)
	return a, nil
}

func (s *artworkService) GetFeed(requesterID string, limit, offset int) ([]*domain.Artwork, error) {
	artworks, err := s.artworkRepo.Feed(limit, offset)
	if err != nil {
		return nil, err
	}
	for _, a := range artworks {
		a.Liked, _ = s.artworkRepo.IsLiked(a.ID, requesterID)
		a.LikeCount, _ = s.artworkRepo.CountLikes(a.ID)
	}
	return artworks, nil
}

func (s *artworkService) GetByUser(userID string, limit, offset int) ([]*domain.Artwork, error) {
	return s.artworkRepo.FindByUserID(userID, limit, offset)
}

func (s *artworkService) Update(artworkID, userID, title string, pixels domain.PixelMap) (*domain.Artwork, error) {
	a, err := s.artworkRepo.FindByID(artworkID)
	if err != nil {
		return nil, err
	}
	if a.UserID != userID {
		return nil, domain.ErrNotArtworkOwner
	}
	if title != "" {
		a.Title = title
	}
	if pixels != nil {
		a.Pixels = pixels
	}
	a.UpdatedAt = time.Now()
	if err := s.artworkRepo.Update(a); err != nil {
		return nil, err
	}
	return a, nil
}

func (s *artworkService) Delete(artworkID, userID string) error {
	a, err := s.artworkRepo.FindByID(artworkID)
	if err != nil {
		return err
	}
	if a.UserID != userID {
		return domain.ErrNotArtworkOwner
	}
	return s.artworkRepo.Delete(artworkID)
}

func (s *artworkService) Like(artworkID, userID string) error {
	a, err := s.artworkRepo.FindByID(artworkID)
	if err != nil {
		return err
	}
	if err := s.artworkRepo.Like(artworkID, userID); err != nil {
		return err
	}
	// Cria notificação para o dono da arte (se não for ele mesmo curtindo)
	if a.UserID != userID {
		n := &domain.Notification{
			ID:        uuid.NewString(),
			UserID:    a.UserID,
			ActorID:   userID,
			Type:      domain.NotificationTypeLike,
			ArtworkID: &artworkID,
			CreatedAt: time.Now(),
		}
		_ = s.notificationRepo.Create(n)
	}
	return nil
}

func (s *artworkService) Unlike(artworkID, userID string) error {
	if _, err := s.artworkRepo.FindByID(artworkID); err != nil {
		return err
	}
	return s.artworkRepo.Unlike(artworkID, userID)
}
