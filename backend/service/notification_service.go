package service

import "github.com/socialpixel/backend/domain"

type notificationService struct {
	repo domain.NotificationRepository
}

func NewNotificationService(repo domain.NotificationRepository) domain.NotificationService {
	return &notificationService{repo: repo}
}

func (s *notificationService) GetForUser(userID string, limit, offset int) ([]*domain.Notification, error) {
	return s.repo.FindByUserID(userID, limit, offset)
}

func (s *notificationService) MarkAllAsRead(userID string) error {
	return s.repo.MarkAllAsRead(userID)
}

func (s *notificationService) CountUnread(userID string) (int, error) {
	return s.repo.CountUnread(userID)
}
