package repository

import (
	"database/sql"

	"github.com/socialpixel/backend/domain"
)

type notificationRepository struct {
	db *sql.DB
}

func NewNotificationRepository(db *sql.DB) domain.NotificationRepository {
	return &notificationRepository{db: db}
}

func (r *notificationRepository) Create(n *domain.Notification) error {
	_, err := r.db.Exec(`
		INSERT INTO notifications (id, user_id, actor_id, type, artwork_id, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)`,
		n.ID, n.UserID, n.ActorID, n.Type, n.ArtworkID, n.CreatedAt,
	)
	return err
}

func (r *notificationRepository) FindByUserID(userID string, limit, offset int) ([]*domain.Notification, error) {
	rows, err := r.db.Query(`
		SELECT n.id, n.user_id, n.actor_id, n.type, n.artwork_id, n.read_at, n.created_at,
		       u.id, u.username, u.avatar_url
		FROM notifications n
		JOIN users u ON u.id = n.actor_id
		WHERE n.user_id = $1
		ORDER BY n.created_at DESC
		LIMIT $2 OFFSET $3`, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []*domain.Notification
	for rows.Next() {
		n := &domain.Notification{Actor: &domain.User{}}
		if err := rows.Scan(
			&n.ID, &n.UserID, &n.ActorID, &n.Type, &n.ArtworkID, &n.ReadAt, &n.CreatedAt,
			&n.Actor.ID, &n.Actor.Username, &n.Actor.AvatarURL,
		); err != nil {
			return nil, err
		}
		list = append(list, n)
	}
	return list, rows.Err()
}

func (r *notificationRepository) MarkAllAsRead(userID string) error {
	_, err := r.db.Exec(
		`UPDATE notifications SET read_at = NOW() WHERE user_id = $1 AND read_at IS NULL`,
		userID,
	)
	return err
}

func (r *notificationRepository) CountUnread(userID string) (int, error) {
	var count int
	err := r.db.QueryRow(
		`SELECT COUNT(*) FROM notifications WHERE user_id = $1 AND read_at IS NULL`,
		userID,
	).Scan(&count)
	return count, err
}
