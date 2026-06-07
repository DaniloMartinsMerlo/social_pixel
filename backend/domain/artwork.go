package domain

import (
	"errors"
	"time"
)

var (
	ErrArtworkNotFound   = errors.New("artwork not found")
	ErrNotArtworkOwner   = errors.New("user is not the artwork owner")
	ErrInvalidCanvasSize = errors.New("invalid canvas size: use 12, 16, 24, 32, 48 or 64")
)

var AllowedSizes = map[int]bool{
	12: true, 16: true, 24: true,
	32: true, 48: true, 64: true,
}

type PixelMap map[string]string

type ArtworkCreateRequest struct {
	Title  string   `json:"title" binding:"required,max=100"`
	Width  int      `json:"width" binding:"required"`
	Height int      `json:"height" binding:"required"`
	Pixels PixelMap `json:"pixels" binding:"required"`
}

type ArtworkUpdateRequest struct {
	Title  string   `json:"title" binding:"omitempty,max=100"`
	Pixels PixelMap `json:"pixels"`
}

type Artwork struct {
	ID        string    `json:"id"`
	UserID    string    `json:"user_id"`
	Author    *User     `json:"author,omitempty"`
	Title     string    `json:"title"`
	Width     int       `json:"width"`
	Height    int       `json:"height"`
	Pixels    PixelMap  `json:"pixels"`
	LikeCount int       `json:"like_count"`
	Liked     bool      `json:"liked"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type ArtworkRepository interface {
	Create(a *Artwork) error
	FindByID(id string) (*Artwork, error)
	FindByUserID(userID string, limit, offset int) ([]*Artwork, error)
	Feed(limit, offset int) ([]*Artwork, error)
	Update(a *Artwork) error
	Delete(id string) error
	Like(artworkID, userID string) error
	Unlike(artworkID, userID string) error
	IsLiked(artworkID, userID string) (bool, error)
	CountLikes(artworkID string) (int, error)
}

type ArtworkService interface {
	Create(userID, title string, width, height int, pixels PixelMap) (*Artwork, error)
	GetByID(artworkID, requesterID string) (*Artwork, error)
	GetFeed(requesterID string, limit, offset int) ([]*Artwork, error)
	GetByUser(userID string, limit, offset int) ([]*Artwork, error)
	Update(artworkID, userID, title string, pixels PixelMap) (*Artwork, error)
	Delete(artworkID, userID string) error
	Like(artworkID, userID string) error
	Unlike(artworkID, userID string) error
}
