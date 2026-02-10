// ═════════════════════════════════════════════════════════════════════════════
// Auth Service - Authentication & Authorization
// ═══════════════════════════════════════════════════════════════════════════════

package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/exporters/jaeger"
	"go.opentelemetry.io//sdk/trace"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/reflection"
	"google.golang.org/grpc/status"

	sharedAuth "shared/pkg/grpc/auth/v1"
)

// ────────────────────────────────────────────────────────────────────────────────
// Server Implementation
// ────────────────────────────────────────────────────────────────────────────────

type server struct {
	sharedAuth.UnimplementedAuthServiceServer
	// Add dependencies: database, redis, etc.
}

func NewServer() *server {
	return &server{}
}

// Login implements auth.v1.AuthService/Login
func (s *server) Login(ctx context.Context, req *sharedAuth.LoginRequest) (*sharedAuth.LoginResponse, error) {
	// Add tracing span
	ctx, span := otel.Tracer("auth-service").Start(ctx, "Login")
	defer span.End()

	// Validate credentials (in real service, check database)
	if req.Email == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "email and password required")
	}

	// TODO: Verify password hash
	// TODO: Generate JWT token
	// TODO: Log login event

	return &sharedAuth.LoginResponse{
		AccessToken:  "jwt_token_here",
		RefreshToken: "refresh_token_here",
		ExpiresIn:    3600,
		User: &sharedAuth.User{
			Id:    "user_123",
			Email: req.Email,
		},
	}, nil
}

// Register implements auth.v1.AuthService/Register
func (s *server) Register(ctx context.Context, req *sharedAuth.RegisterRequest) (*sharedAuth.RegisterResponse, error) {
	ctx, span := otel.Tracer("auth-service").Start(ctx, "Register")
	defer span.End()

	// Validate input
	if req.Email == "" || req.Password == "" {
		return nil, status.Error(codes.InvalidArgument, "email and password required")
	}

	// TODO: Check if user exists
	// TODO: Hash password
	// TODO: Create user in database
	// TODO: Publish UserCreated event to NATS

	return &sharedAuth.RegisterResponse{
		User: &sharedAuth.User{
			Id:    "new_user_123",
			Email: req.Email,
		},
	}, nil
}

// RefreshToken implements auth.v1.AuthService/RefreshToken
func (s *server) RefreshToken(ctx context.Context, req *sharedAuth.RefreshTokenRequest) (*sharedAuth.RefreshTokenResponse, error) {
	ctx, span := otel.Tracer("auth-service").Start(ctx, "RefreshToken")
	defer span.End()

	// TODO: Validate refresh token
	// TODO: Generate new access token

	return &sharedAuth.RefreshTokenResponse{
		AccessToken: "new_jwt_token_here",
		ExpiresIn:   3600,
	}, nil
}

// Logout implements auth.v1.AuthService/Logout
func (s *server) Logout(ctx context.Context, req *sharedAuth.LogoutRequest) (*sharedAuth.LogoutResponse, error) {
	ctx, span := otel.Tracer("auth-service").Start(ctx, "Logout")
	defer span.End()

	// TODO: Invalidate token in Redis

	return &sharedAuth.LogoutResponse{
		Success: true,
	}, nil
}

// ────────────────────────────────────────────────────────────────────────────────
// HTTP Handlers (for health, metrics, etc.)
// ────────────────────────────────────────────────────────────────────────────────

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status":"healthy"}`)
}

func metricsHandler(w http.ResponseWriter, r *http.Request) {
	// TODO: Expose Prometheus metrics
	w.WriteHeader(http.StatusOK)
}

// ────────────────────────────────────────────────────────────────────────────────
// OpenTelemetry Initialization
// ────────────────────────────────────────────────────────────────────────────────

func initTracing(serviceName string) {
	// Create Jaeger exporter
	jaegerEndpoint := os.Getenv("JAEGER_ENDPOINT")
	if jaegerEndpoint == "" {
		jaegerEndpoint = "http://jaeger:14268/api/traces"
	}

	exporter, err := jaeger.New(jaeger.WithCollectorEndpoint(
		jaeger.WithEndpoint(jaegerEndpoint),
	))
	if err != nil {
		log.Fatalf("Failed to create Jaeger exporter: %v", err)
	}

	// Create tracer provider
	tp := trace.NewTracerProvider(
		trace.WithBatcher(exporter),
		trace.WithResource(trace.NewResource(serviceName)),
	)

	// Register global tracer provider
	otel.SetTracerProvider(tp)
}

// ────────────────────────────────────────────────────────────────────────────────
// Main
// ────────────────────────────────────────────────────────────────────────────────

func main() {
	// Initialize tracing
	initTracing("auth-service")

	// Get configuration
	grpcPort := os.Getenv("GRPC_PORT")
	if grpcPort == "" {
		grpcPort = "8001"
	}

	httpPort := os.Getenv("HTTP_PORT")
	if httpPort == "" {
		httpPort = "8081"
	}

	// Create gRPC server with interceptors
	s := grpc.NewServer(
		grpc.ChainUnaryInterceptor(
			// OpenTelemetry interceptor
			otelgrpc.UnaryServerInterceptor(),
			// Logging interceptor
			func(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
				start := time.Now()
				resp, err := handler(ctx, req)
				log.Printf("%s took %v", info.FullMethod, time.Since(start))
				return resp, err
			},
		),
	)

	// Register service
	sharedAuth.RegisterAuthServiceServer(s, NewServer())

	// Register reflection (useful for debugging)
	reflection.Register(s)

	// Start gRPC server in background
	go func() {
		lis, err := net.Listen("tcp", ":"+grpcPort)
		if err != nil {
			log.Fatalf("Failed to listen: %v", err)
		}
		log.Printf("Auth service (gRPC) listening on :%s", grpcPort)
		if err := s.Serve(lis); err != nil {
			log.Fatalf("Failed to serve: %v", err)
		}
	}()

	// Start HTTP server for health/metrics
	go func() {
		http.HandleFunc("/health", healthHandler)
		http.HandleFunc("/metrics", metricsHandler)
		log.Printf("Auth service (HTTP) listening on :%s", httpPort)
		if err := http.ListenAndServe(":"+httpPort, nil); err != nil {
			log.Fatalf("HTTP server failed: %v", err)
		}
	}()

	// Wait for interrupt signal
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("Shutting down servers...")
	s.GracefulStop()
}
