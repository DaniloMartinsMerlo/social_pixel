package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"

	"github.com/socialpixel/backend/handler"
	"github.com/socialpixel/backend/repository"
	"github.com/socialpixel/backend/service"
)

func main() {
	db := connectDB()
	migrate(db)

	// Repositories
	userRepo := repository.NewUserRepository(db)
	artworkRepo := repository.NewArtworkRepository(db)
	notificationRepo := repository.NewNotificationRepository(db)

	// Services
	userSvc := service.NewUserService(userRepo)
	artworkSvc := service.NewArtworkService(artworkRepo, notificationRepo)
	notificationSvc := service.NewNotificationService(notificationRepo)

	// Handlers
	userH := handler.NewUserHandler(userSvc)
	artworkH := handler.NewArtworkHandler(artworkSvc)
	notificationH := handler.NewNotificationHandler(notificationSvc)

	r := gin.Default()
	r.Use(cors())

	// no swagger UI configured

	// Users
	r.POST("/users/register", userH.Register)
	r.POST("/users/login", userH.Login)
	r.GET("/users/:id", userH.GetProfile)
	r.PATCH("/users/:id", userH.UpdateProfile)
	r.GET("/users/:id/artworks", artworkH.GetByUser)

	// Artworks
	r.GET("/artworks/feed", artworkH.GetFeed)
	r.GET("/artworks/:id", artworkH.GetByID)
	r.POST("/artworks", artworkH.Create)
	r.PATCH("/artworks/:id", artworkH.Update)
	r.DELETE("/artworks/:id", artworkH.Delete)
	r.POST("/artworks/:id/like", artworkH.Like)
	r.DELETE("/artworks/:id/like", artworkH.Unlike)

	// Notifications
	r.GET("/notifications", notificationH.List)
	r.GET("/notifications/unread", notificationH.CountUnread)
	r.PATCH("/notifications/read", notificationH.MarkAllAsRead)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("server running on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}

func connectDB() *sql.DB {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		// fallback para variáveis individuais
		dsn = fmt.Sprintf(
			"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
			getenv("DB_HOST", "db.mdahkotjozifhfqieafv.supabase.co"),
			getenv("DB_PORT", "5432"),
			getenv("DB_USER", "postgres"),
			getenv("DB_PASSWORD", ""),
			getenv("DB_NAME", "postgres"),
			getenv("DB_SSLMODE", "require"),
		)
	}

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("failed to open db: %v", err)
	}
	if err := db.Ping(); err != nil {
		log.Fatalf("failed to connect to db: %v", err)
	}
	db.SetMaxOpenConns(10)
	log.Println("database connected")
	return db
}

func migrate(db *sql.DB) {
	stmts := []string{
		`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`,

		`CREATE TABLE IF NOT EXISTS users (
			id         TEXT        PRIMARY KEY,
			username   VARCHAR(50) NOT NULL UNIQUE,
			email      VARCHAR(255) NOT NULL UNIQUE,
			password   TEXT        NOT NULL DEFAULT '',
			avatar_url TEXT        NOT NULL DEFAULT '',
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		`ALTER TABLE users ADD COLUMN IF NOT EXISTS password TEXT NOT NULL DEFAULT ''`,

		`CREATE TABLE IF NOT EXISTS artworks (
			id         TEXT        PRIMARY KEY,
			user_id    TEXT        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
			title      VARCHAR(100) NOT NULL,
			width      INT         NOT NULL,
			height     INT         NOT NULL,
			pixels     JSONB       NOT NULL DEFAULT '{}',
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)`,

		`CREATE TABLE IF NOT EXISTS likes (
			artwork_id TEXT        NOT NULL REFERENCES artworks(id) ON DELETE CASCADE,
			user_id    TEXT        NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
			created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
			PRIMARY KEY (artwork_id, user_id)
		)`,

		`CREATE TABLE IF NOT EXISTS notifications (
			id         TEXT             PRIMARY KEY,
			user_id    TEXT             NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
			actor_id   TEXT             NOT NULL REFERENCES users(id)    ON DELETE CASCADE,
			type       VARCHAR(50)      NOT NULL,
			artwork_id TEXT             REFERENCES artworks(id)          ON DELETE CASCADE,
			read_at    TIMESTAMPTZ,
			created_at TIMESTAMPTZ      NOT NULL DEFAULT NOW()
		)`,
	}

	for _, s := range stmts {
		if _, err := db.Exec(s); err != nil {
			log.Fatalf("migration error: %v\n%s", err, s)
		}
	}
	log.Println("migrations ok")
}

func cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PATCH, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type")
		if c.Request.Method == http.MethodOptions {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}
		c.Next()
	}
}

func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
