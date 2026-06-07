package repository

import (
	"database/sql"
	"encoding/json"
	"errors"

	"github.com/socialpixel/backend/domain"
)

type artworkRepository struct {
	db *sql.DB
}

func NewArtworkRepository(db *sql.DB) domain.ArtworkRepository {
	return &artworkRepository{db: db}
}

func (r *artworkRepository) Create(a *domain.Artwork) error {
	pixels, err := json.Marshal(a.Pixels)
	if err != nil {
		return err
	}
	_, err = r.db.Exec(`
		INSERT INTO artworks (id, user_id, title, width, height, pixels, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
		a.ID, a.UserID, a.Title, a.Width, a.Height, pixels, a.CreatedAt, a.UpdatedAt,
	)
	return err
}

func (r *artworkRepository) FindByID(id string) (*domain.Artwork, error) {
	row := r.db.QueryRow(`
		SELECT a.id, a.user_id, a.title, a.width, a.height, a.pixels, a.created_at, a.updated_at,
		       u.id, u.username, u.avatar_url
		FROM artworks a
		JOIN users u ON u.id = a.user_id
		WHERE a.id = $1`, id)

	return r.scanOne(row)
}

func (r *artworkRepository) FindByUserID(userID string, limit, offset int) ([]*domain.Artwork, error) {
	rows, err := r.db.Query(`
		SELECT a.id, a.user_id, a.title, a.width, a.height, a.pixels, a.created_at, a.updated_at,
		       u.id, u.username, u.avatar_url
		FROM artworks a
		JOIN users u ON u.id = a.user_id
		WHERE a.user_id = $1
		ORDER BY a.created_at DESC
		LIMIT $2 OFFSET $3`, userID, limit, offset)
	if err != nil {
		return nil, err
	}
	return r.scanMany(rows)
}

func (r *artworkRepository) Feed(limit, offset int) ([]*domain.Artwork, error) {
	rows, err := r.db.Query(`
		SELECT a.id, a.user_id, a.title, a.width, a.height, a.pixels, a.created_at, a.updated_at,
		       u.id, u.username, u.avatar_url
		FROM artworks a
		JOIN users u ON u.id = a.user_id
		ORDER BY a.created_at DESC
		LIMIT $1 OFFSET $2`, limit, offset)
	if err != nil {
		return nil, err
	}
	return r.scanMany(rows)
}

func (r *artworkRepository) Update(a *domain.Artwork) error {
	pixels, err := json.Marshal(a.Pixels)
	if err != nil {
		return err
	}
	_, err = r.db.Exec(
		`UPDATE artworks SET title = $1, pixels = $2, updated_at = $3 WHERE id = $4`,
		a.Title, pixels, a.UpdatedAt, a.ID,
	)
	return err
}

func (r *artworkRepository) Delete(id string) error {
	_, err := r.db.Exec(`DELETE FROM artworks WHERE id = $1`, id)
	return err
}

func (r *artworkRepository) Like(artworkID, userID string) error {
	_, err := r.db.Exec(
		`INSERT INTO likes (artwork_id, user_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
		artworkID, userID,
	)
	return err
}

func (r *artworkRepository) Unlike(artworkID, userID string) error {
	_, err := r.db.Exec(
		`DELETE FROM likes WHERE artwork_id = $1 AND user_id = $2`,
		artworkID, userID,
	)
	return err
}

func (r *artworkRepository) IsLiked(artworkID, userID string) (bool, error) {
	var exists bool
	err := r.db.QueryRow(
		`SELECT EXISTS(SELECT 1 FROM likes WHERE artwork_id = $1 AND user_id = $2)`,
		artworkID, userID,
	).Scan(&exists)
	return exists, err
}

func (r *artworkRepository) CountLikes(artworkID string) (int, error) {
	var count int
	err := r.db.QueryRow(`SELECT COUNT(*) FROM likes WHERE artwork_id = $1`, artworkID).Scan(&count)
	return count, err
}

func (r *artworkRepository) scanOne(row *sql.Row) (*domain.Artwork, error) {
	a := &domain.Artwork{Author: &domain.User{}}
	var raw []byte
	err := row.Scan(
		&a.ID, &a.UserID, &a.Title, &a.Width, &a.Height, &raw, &a.CreatedAt, &a.UpdatedAt,
		&a.Author.ID, &a.Author.Username, &a.Author.AvatarURL,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, domain.ErrArtworkNotFound
	}
	if err != nil {
		return nil, err
	}
	return a, json.Unmarshal(raw, &a.Pixels)
}

func (r *artworkRepository) scanMany(rows *sql.Rows) ([]*domain.Artwork, error) {
	defer rows.Close()
	var list []*domain.Artwork
	for rows.Next() {
		a := &domain.Artwork{Author: &domain.User{}}
		var raw []byte
		if err := rows.Scan(
			&a.ID, &a.UserID, &a.Title, &a.Width, &a.Height, &raw, &a.CreatedAt, &a.UpdatedAt,
			&a.Author.ID, &a.Author.Username, &a.Author.AvatarURL,
		); err != nil {
			return nil, err
		}
		if err := json.Unmarshal(raw, &a.Pixels); err != nil {
			return nil, err
		}
		list = append(list, a)
	}
	return list, rows.Err()
}
