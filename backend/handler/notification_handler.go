package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/socialpixel/backend/domain"
)

type NotificationHandler struct {
	service domain.NotificationService
}

func NewNotificationHandler(s domain.NotificationService) *NotificationHandler {
	return &NotificationHandler{service: s}
}

func (h *NotificationHandler) List(c *gin.Context) {
	userID, ok := currentUserID(c)
	if !ok {
		return
	}
	limit, offset := pagination(c)

	notifications, err := h.service.GetForUser(userID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": notifications})
}

func (h *NotificationHandler) CountUnread(c *gin.Context) {
	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	count, err := h.service.CountUnread(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": gin.H{"unread": count}})
}

func (h *NotificationHandler) MarkAllAsRead(c *gin.Context) {
	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	if err := h.service.MarkAllAsRead(userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.Status(http.StatusNoContent)
}
