package handler

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/socialpixel/backend/domain"
)

type ArtworkHandler struct {
	service domain.ArtworkService
}

func NewArtworkHandler(s domain.ArtworkService) *ArtworkHandler {
	return &ArtworkHandler{service: s}
}

func (h *ArtworkHandler) GetFeed(c *gin.Context) {
	requesterID, ok := currentUserID(c)
	if !ok {
		return
	}
	limit, offset := pagination(c)

	artworks, err := h.service.GetFeed(requesterID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": artworks})
}

func (h *ArtworkHandler) GetByUser(c *gin.Context) {
	limit, offset := pagination(c)
	artworks, err := h.service.GetByUser(c.Param("id"), limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": artworks})
}

func (h *ArtworkHandler) GetByID(c *gin.Context) {
	requesterID, ok := currentUserID(c)
	if !ok {
		return
	}
	artwork, err := h.service.GetByID(c.Param("id"), requesterID)
	if err != nil {
		if errors.Is(err, domain.ErrArtworkNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "artwork not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": artwork})
}

func (h *ArtworkHandler) Create(c *gin.Context) {
	var req domain.ArtworkCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	artwork, err := h.service.Create(userID, req.Title, req.Width, req.Height, req.Pixels)
	if err != nil {
		if errors.Is(err, domain.ErrInvalidCanvasSize) {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"data": artwork})
}

func (h *ArtworkHandler) Update(c *gin.Context) {
	var req domain.ArtworkUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	artwork, err := h.service.Update(c.Param("id"), userID, req.Title, req.Pixels)
	if err != nil {
		switch {
		case errors.Is(err, domain.ErrArtworkNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "artwork not found"})
		case errors.Is(err, domain.ErrNotArtworkOwner):
			c.JSON(http.StatusForbidden, gin.H{"error": "you do not own this artwork"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		}
		return
	}
	c.JSON(http.StatusOK, gin.H{"data": artwork})
}

func (h *ArtworkHandler) Delete(c *gin.Context) {
	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	err := h.service.Delete(c.Param("id"), userID)
	if err != nil {
		switch {
		case errors.Is(err, domain.ErrArtworkNotFound):
			c.JSON(http.StatusNotFound, gin.H{"error": "artwork not found"})
		case errors.Is(err, domain.ErrNotArtworkOwner):
			c.JSON(http.StatusForbidden, gin.H{"error": "you do not own this artwork"})
		default:
			c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		}
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *ArtworkHandler) Like(c *gin.Context) {
	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	if err := h.service.Like(c.Param("id"), userID); err != nil {
		if errors.Is(err, domain.ErrArtworkNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "artwork not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.Status(http.StatusNoContent)
}

func (h *ArtworkHandler) Unlike(c *gin.Context) {
	userID, ok := currentUserID(c)
	if !ok {
		return
	}

	if err := h.service.Unlike(c.Param("id"), userID); err != nil {
		if errors.Is(err, domain.ErrArtworkNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "artwork not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	c.Status(http.StatusNoContent)
}

func pagination(c *gin.Context) (limit, offset int) {
	limit, _ = strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset, _ = strconv.Atoi(c.DefaultQuery("offset", "0"))
	if limit <= 0 || limit > 100 {
		limit = 20
	}
	if offset < 0 {
		offset = 0
	}
	return
}

func currentUserID(c *gin.Context) (string, bool) {
	userID := c.GetHeader("X-User-Id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "X-User-Id header is required"})
		return "", false
	}
	return userID, true
}
