package domain

import "time"

type NotificationType string

const (
	NotificationTypeLike NotificationType = "like"
)

type Notification struct {
	ID        string           `json:"id"`
	UserID    string           `json:"user_id"`
	ActorID   string           `json:"actor_id"`
	Actor     *User            `json:"actor,omitempty"`
	Type      NotificationType `json:"type"`
	ArtworkID *string          `json:"artwork_id,omitempty"`
	ReadAt    *time.Time       `json:"read_at"`
	CreatedAt time.Time        `json:"created_at"`
}

type NotificationRepository interface {
	Create(n *Notification) error
	FindByUserID(userID string, limit, offset int) ([]*Notification, error)
	MarkAllAsRead(userID string) error
	CountUnread(userID string) (int, error)
}

type NotificationService interface {
	GetForUser(userID string, limit, offset int) ([]*Notification, error)
	MarkAllAsRead(userID string) error
	CountUnread(userID string) (int, error)
}
