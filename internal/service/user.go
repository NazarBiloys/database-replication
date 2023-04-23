package service

import (
	"crypto/md5"
	"database/sql"
	"encoding/hex"
	"fmt"
	_ "github.com/go-sql-driver/mysql"
	"time"
)

func MakeUser() error {
	db, err := sql.Open("mysql", "admin:admin@tcp(mysql-master:3306)/test")

	if err != nil {
		return err
	}
	// See "Important settings" section.
	db.SetConnMaxLifetime(time.Minute * 3)
	db.SetMaxOpenConns(10)
	db.SetMaxIdleConns(10)

	hasher := md5.New()
	hasher.Write([]byte(String(10)))

	sql := fmt.Sprintf(
		"INSERT INTO users(firstname, lastname, email, password, date_of_birth) VALUES ('%s', '%s', '%s', '%s', '%s')",
		String(10),
		String(10),
		fmt.Sprintf("%s@example.com", String(10)),
		hex.EncodeToString(hasher.Sum(nil)),
		Rundate(),
	)

	res, err := db.Exec(sql)

	defer db.Close()

	if err != nil {
		return err
	}

	lastId, err := res.LastInsertId()

	if err != nil {
		return err
	}

	fmt.Printf("The last inserted row id: %d\n", lastId)

	return nil
}
