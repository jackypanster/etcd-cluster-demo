# 使用官方Go镜像作为构建环境
FROM golang:1.21.6 as builder

# 设置工作目录
WORKDIR /app

COPY . .
# COPY config.yaml .
# COPY main.go .

# 复制go mod和sum文件
COPY go.mod go.sum ./

ENV GOPROXY=https://goproxy.io,direct

# 下载依赖
RUN go mod download

# 复制源代码
# COPY . .

# 构建应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# 使用scratch作为基础镜像
FROM scratch

# 从构建器中复制编译好的应用
COPY --from=builder /app/main .
COPY --from=builder /app/config.yaml .

# 设置运行时的监听端口
EXPOSE 8080

# 运行应用
CMD ["./main"]