package repository

import (
	"database/sql"
	"errors"
	"strings"

	"github.com/socialpixel/backend/domain"
)

type userRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) domain.UserRepository {
	return &userRepository{db: db}
}

func (r *userRepository) Create(u *domain.User) error {
	query := `
		INSERT INTO users (id, username, email, password, avatar_url, created_at)
		VALUES ($1, $2, $3, $4, $5, $6)`

	_, err := r.db.Exec(query, u.ID, u.Username, u.Email, u.Password, u.AvatarURL, u.CreatedAt)
	if err != nil && isUniqueViolation(err) {
		return domain.ErrEmailAlreadyInUse
	}
	return err
}

func (r *userRepository) FindByID(id string) (*domain.User, error) {
	query := `SELECT id, username, email, password, avatar_url, created_at FROM users WHERE id = $1`
	return r.scan(r.db.QueryRow(query, id))
}

func (r *userRepository) FindByEmail(email string) (*domain.User, error) {
	query := `SELECT id, username, email, password, avatar_url, created_at FROM users WHERE email = $1`
	return r.scan(r.db.QueryRow(query, email))
}

func (r *userRepository) Update(u *domain.User) error {
	_, err := r.db.Exec(
		`UPDATE users SET username = $1, avatar_url = $2 WHERE id = $3`,
		u.Username, u.AvatarURL, u.ID,
	)
	return err
}

func (r *userRepository) scan(row *sql.Row) (*domain.User, error) {
	u := &domain.User{}
	err := row.Scan(&u.ID, &u.Username, &u.Email, &u.Password, &u.AvatarURL, &u.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, domain.ErrUserNotFound
	}
	return u, err
}

func isUniqueViolation(err error) bool {
	return strings.Contains(err.Error(), "unique") || strings.Contains(err.Error(), "duplicate")
}
