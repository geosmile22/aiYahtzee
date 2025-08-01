# Backend Specification - Yahtzee Game

## Technology Stack
- **Runtime**: Node.js 18.0+
- **Framework**: Express.js 4.18+
- **Language**: TypeScript 5.0+
- **Database**: MongoDB 6.0+ with Mongoose 7.0+
- **Authentication**: JWT (jsonwebtoken)
- **Real-time**: Socket.IO 4.6+
- **Validation**: Joi
- **Testing**: Jest + Supertest
- **Documentation**: Swagger/OpenAPI

## Project Structure
```
server/
├── src/
│   ├── controllers/        # Route handlers
│   ├── middleware/         # Express middleware
│   ├── models/            # Mongoose models
│   ├── routes/            # Route definitions
│   ├── services/          # Business logic
│   ├── utils/             # Helper functions
│   ├── validation/        # Input validation schemas
│   ├── types/             # TypeScript interfaces
│   ├── config/            # Configuration files
│   └── app.ts
├── tests/                 # Test files
├── package.json
├── tsconfig.json
└── nodemon.json
```

## Database Schema

### User Model
```typescript
interface IUser {
  _id: ObjectId;
  username: string;           // Unique, 3-20 chars
  email: string;             // Unique, valid email
  password: string;          // Hashed with bcrypt
  profile: {
    firstName?: string;
    lastName?: string;
    avatar?: string;
  };
  stats: {
    gamesPlayed: number;
    gamesWon: number;
    highScore: number;
    averageScore: number;
    yahtzees: number;
  };
  createdAt: Date;
  updatedAt: Date;
  lastLogin: Date;
}
```

### Game Model
```typescript
interface IGame {
  _id: ObjectId;
  gameId: string;            // Unique game identifier
  status: 'waiting' | 'active' | 'finished' | 'abandoned';
  players: Array<{
    userId: ObjectId;
    username: string;
    joinedAt: Date;
    isHost: boolean;
  }>;
  settings: {
    maxPlayers: number;      // 2-6
    isPrivate: boolean;
    password?: string;
  };
  gameState: {
    currentPlayerIndex: number;
    round: number;           // 1-13
    turn: number;
    dice: number[];          // [1-6, 1-6, 1-6, 1-6, 1-6]
    diceHeld: boolean[];     // [false, false, false, false, false]
    rollsRemaining: number;  // 0-3
    scorecards: Record<string, IScorecard>;
    winner?: string;
  };
  createdAt: Date;
  updatedAt: Date;
  finishedAt?: Date;
}

interface IScorecard {
  // Upper Section
  ones?: number;
  twos?: number;
  threes?: number;
  fours?: number;
  fives?: number;
  sixes?: number;
  upperBonus?: number;       // Auto-calculated
  upperTotal?: number;       // Auto-calculated
  
  // Lower Section
  threeOfAKind?: number;
  fourOfAKind?: number;
  fullHouse?: number;
  smallStraight?: number;
  largeStraight?: number;
  yahtzee?: number;
  chance?: number;
  yahtzeeBonus?: number;     // Multiple yahtzees
  lowerTotal?: number;       // Auto-calculated
  grandTotal?: number;       // Auto-calculated
}
```

### GameHistory Model
```typescript
interface IGameHistory {
  _id: ObjectId;
  gameId: ObjectId;
  players: Array<{
    userId: ObjectId;
    username: string;
    finalScore: number;
    scorecard: IScorecard;
    placement: number;
  }>;
  winner: ObjectId;
  duration: number;          // Game duration in milliseconds
  createdAt: Date;
}
```

## API Endpoints

### Authentication Routes
```
POST   /api/auth/register      # User registration
POST   /api/auth/login         # User login
POST   /api/auth/refresh       # Refresh JWT token
POST   /api/auth/logout        # Logout (blacklist token)
POST   /api/auth/forgot        # Forgot password
POST   /api/auth/reset         # Reset password
```

### User Routes
```
GET    /api/users/profile      # Get current user profile
PUT    /api/users/profile      # Update user profile
GET    /api/users/stats        # Get user statistics
GET    /api/users/history      # Get game history
DELETE /api/users/account      # Delete user account
```

### Game Management Routes
```
POST   /api/games             # Create new game
GET    /api/games             # Get available games
GET    /api/games/:id         # Get specific game
POST   /api/games/:id/join    # Join game
POST   /api/games/:id/leave   # Leave game
DELETE /api/games/:id         # Delete game (host only)
```

### Game Action Routes
```
POST   /api/games/:id/roll    # Roll dice
POST   /api/games/:id/hold    # Hold/unhold dice
POST   /api/games/:id/score   # Score category
POST   /api/games/:id/turn    # End turn
```

## Controllers

### AuthController
```typescript
class AuthController {
  register(req: Request, res: Response): Promise<void>;
  login(req: Request, res: Response): Promise<void>;
  refresh(req: Request, res: Response): Promise<void>;
  logout(req: Request, res: Response): Promise<void>;
  forgotPassword(req: Request, res: Response): Promise<void>;
  resetPassword(req: Request, res: Response): Promise<void>;
}
```

### GameController
```typescript
class GameController {
  createGame(req: Request, res: Response): Promise<void>;
  getGames(req: Request, res: Response): Promise<void>;
  getGame(req: Request, res: Response): Promise<void>;
  joinGame(req: Request, res: Response): Promise<void>;
  leaveGame(req: Request, res: Response): Promise<void>;
  deleteGame(req: Request, res: Response): Promise<void>;
}
```

### GameActionController
```typescript
class GameActionController {
  rollDice(req: Request, res: Response): Promise<void>;
  holdDice(req: Request, res: Response): Promise<void>;
  scoreCategory(req: Request, res: Response): Promise<void>;
  endTurn(req: Request, res: Response): Promise<void>;
}
```

## Services

### GameService
```typescript
class GameService {
  createGame(hostId: string, settings: GameSettings): Promise<IGame>;
  joinGame(gameId: string, userId: string): Promise<IGame>;
  leaveGame(gameId: string, userId: string): Promise<IGame>;
  rollDice(gameId: string, userId: string): Promise<GameState>;
  holdDice(gameId: string, userId: string, indices: number[]): Promise<GameState>;
  scoreCategory(gameId: string, userId: string, category: string): Promise<GameState>;
  endTurn(gameId: string, userId: string): Promise<GameState>;
  calculateScore(dice: number[], category: string): number;
  checkGameEnd(gameState: GameState): boolean;
  determineWinner(scorecards: Record<string, IScorecard>): string;
}
```

### UserService
```typescript
class UserService {
  createUser(userData: RegisterData): Promise<IUser>;
  getUserById(id: string): Promise<IUser>;
  getUserByEmail(email: string): Promise<IUser>;
  updateUser(id: string, updates: Partial<IUser>): Promise<IUser>;
  updateStats(userId: string, gameResult: GameResult): Promise<void>;
  deleteUser(id: string): Promise<void>;
}
```

### AuthService
```typescript
class AuthService {
  generateTokens(userId: string): TokenPair;
  verifyToken(token: string): Promise<TokenPayload>;
  refreshTokens(refreshToken: string): Promise<TokenPair>;
  hashPassword(password: string): Promise<string>;
  comparePassword(password: string, hash: string): Promise<boolean>;
  blacklistToken(token: string): Promise<void>;
}
```

## Middleware

### Authentication Middleware
```typescript
const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  // Verify JWT token
  // Attach user to request object
  // Handle token expiration
};

const authorize = (roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    // Check user roles/permissions
  };
};
```

### Validation Middleware
```typescript
const validate = (schema: Joi.Schema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    // Validate request body against schema
    // Return validation errors
  };
};
```

### Rate Limiting
```typescript
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,    // 15 minutes
  max: 100,                    // Limit each IP to 100 requests per windowMs
  message: 'Too many requests'
});
```

## Socket.IO Events

### Server Events (Emit)
```typescript
// Game state updates
socket.emit('gameStateUpdate', gameState);
socket.emit('playerJoined', player);
socket.emit('playerLeft', playerId);
socket.emit('turnChanged', currentPlayerId);
socket.emit('gameEnded', winner);
socket.emit('diceRolled', diceResult);
socket.emit('categoryScored', scoreUpdate);

// Errors
socket.emit('error', errorMessage);
socket.emit('gameError', gameErrorMessage);
```

### Client Events (Listen)
```typescript
socket.on('rollDice', handleRollDice);
socket.on('holdDice', handleHoldDice);
socket.on('scoreCategory', handleScoreCategory);
socket.on('endTurn', handleEndTurn);
socket.on('joinGame', handleJoinGame);
socket.on('leaveGame', handleLeaveGame);
```

## Validation Schemas

### User Registration
```typescript
const registerSchema = Joi.object({
  username: Joi.string().alphanum().min(3).max(20).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).required(),
  firstName: Joi.string().max(50).optional(),
  lastName: Joi.string().max(50).optional()
});
```

### Game Creation
```typescript
const createGameSchema = Joi.object({
  maxPlayers: Joi.number().integer().min(2).max(6).default(4),
  isPrivate: Joi.boolean().default(false),
  password: Joi.string().when('isPrivate', {
    is: true,
    then: Joi.string().min(4).max(20).required(),
    otherwise: Joi.forbidden()
  })
});
```

## Error Handling

### Custom Error Classes
```typescript
class AppError extends Error {
  statusCode: number;
  isOperational: boolean;
  
  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

class ValidationError extends AppError {
  constructor(message: string) {
    super(message, 400);
  }
}

class AuthenticationError extends AppError {
  constructor(message: string = 'Authentication failed') {
    super(message, 401);
  }
}

class GameError extends AppError {
  constructor(message: string) {
    super(message, 400);
  }
}
```

### Global Error Handler
```typescript
const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction) => {
  // Log error details
  // Send appropriate error response
  // Handle different error types
};
```

## Security Measures

### Input Validation
- Joi schemas for all inputs
- SQL injection prevention (MongoDB)
- XSS protection
- CSRF tokens

### Authentication Security
- JWT with short expiration
- Refresh token rotation
- Password hashing with bcrypt
- Rate limiting on auth endpoints

### API Security
- Helmet.js for security headers
- CORS configuration
- Input sanitization
- Request size limits

## Configuration

### Environment Variables
```
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/yahtzee
MONGODB_TEST_URI=mongodb://localhost:27017/yahtzee_test

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_SECRET=your-refresh-token-secret
REFRESH_TOKEN_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:3000

# Email (for password reset)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
```

## Testing Strategy

### Unit Tests
- Service layer functions
- Utility functions
- Middleware functions
- Model validations

### Integration Tests
- API endpoint testing
- Database operations
- Authentication flows
- Socket.IO events

### Load Testing
- Concurrent user testing
- Database performance
- Memory usage monitoring
- Response time testing

## Deployment

### Production Setup
```bash
npm run build        # Compile TypeScript
npm run start        # Start production server
npm run test         # Run test suite
npm run migrate      # Database migrations
```

### Docker Configuration
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY dist ./dist
EXPOSE 5000
CMD ["npm", "start"]
```

### Health Checks
```
GET /health          # Basic health check
GET /health/db       # Database connectivity
GET /health/detailed # Comprehensive health status
```