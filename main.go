package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
	clientv3 "go.etcd.io/etcd/client/v3"
)

func main() {
	/*
		cli, err := clientv3.New(clientv3.Config{
			Endpoints:   []string{"localhost:12379", "localhost:22379", "localhost:32379"},
			DialTimeout: 5 * time.Second,
		})
	*/

	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")

	if err := viper.ReadInConfig(); err != nil {
		log.Fatalf("Error reading config file, %s", err)
	}

	endpoints := viper.GetStringSlice("etcd.endpoints")
	username := viper.GetString("etcd.username")
	password := viper.GetString("etcd.password")

	cli, err := clientv3.New(clientv3.Config{
		Endpoints:   endpoints,
		DialTimeout: 5 * time.Second,
		Username:    username,
		Password:    password,
	})

	if err != nil {
		log.Fatalf("Failed to connect to etcd: %v", err)
	}
	defer cli.Close()

	r := gin.Default()
	r.GET("/get/:key", func(c *gin.Context) {
		key := c.Param("key")
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()
		resp, err := cli.Get(ctx, key)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		for _, ev := range resp.Kvs {
			c.JSON(http.StatusOK, gin.H{"key": key, "value": string(ev.Value)})
		}
	})

	r.PUT("/put", func(c *gin.Context) {
		var json struct {
			Key   string `json:"key"`
			Value string `json:"value"`
		}
		if err := c.BindJSON(&json); err != nil {
			return
		}
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()
		_, err = cli.Put(ctx, json.Key, json.Value)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "success"})
	})

	r.DELETE("/delete/:key", func(c *gin.Context) {
		key := c.Param("key")
		ctx, cancel := context.WithTimeout(context.Background(), time.Second)
		defer cancel()
		_, err := cli.Delete(ctx, key)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, gin.H{"status": "success"})
	})

	r.Run(":8080") // listen and serve on 0.0.0.0:8080
}
