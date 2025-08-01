# Frontend Specification - Yahtzee Game

## Technology Stack
- **Framework**: React 18.2+ with TypeScript 5.0+
- **Build Tool**: Vite 4.0+
- **Styling**: Tailwind CSS 3.3+
- **State Management**: React Context API + useReducer
- **Routing**: React Router 6.8+
- **HTTP Client**: Axios
- **Real-time**: Socket.IO Client
- **Testing**: Jest + React Testing Library
- **Linting**: ESLint + Prettier

## Project Structure
```
client/
├── public/
│   ├── index.html
│   ├── favicon.ico
│   └── manifest.json
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── common/         # Generic components
│   │   ├── game/           # Game-specific components
│   │   └── layout/         # Layout components
│   ├── pages/              # Route components
│   ├── hooks/              # Custom React hooks
│   ├── context/            # React Context providers
│   ├── services/           # API and Socket services
│   ├── types/              # TypeScript type definitions
│   ├── utils/              # Helper functions
│   ├── constants/          # App constants
│   ├── styles/             # Global styles
│   └── App.tsx
├── package.json
├── vite.config.ts
├── tailwind.config.js
└── tsconfig.json
```

## Core Components

### Layout Components
- **Header**: Navigation, user menu, game status
- **Sidebar**: Player list, game info, chat
- **Footer**: Game rules link, credits
- **Layout**: Main application wrapper

### Game Components
- **GameBoard**: Main game container
- **DiceContainer**: 5 dice display with hold functionality
- **ScoreCard**: Interactive scoring sheet
- **PlayerTurn**: Current player indicator
- **GameControls**: Roll dice, end turn buttons
- **GameStatus**: Game phase, rolls remaining

### Common Components
- **Button**: Styled button variants
- **Modal**: Reusable modal component
- **LoadingSpinner**: Loading indicator
- **ErrorBoundary**: Error handling wrapper
- **Toast**: Notification system

## Page Components

### AuthPages
- **LoginPage**: User authentication
- **RegisterPage**: User registration
- **ForgotPasswordPage**: Password recovery

### GamePages
- **HomePage**: Dashboard with game options
- **LobbyPage**: Game room before start
- **GamePage**: Active game interface
- **GameHistoryPage**: Past games list
- **ProfilePage**: User profile and stats

## State Management

### Game Context
```typescript
interface GameState {
  gameId: string | null;
  players: Player[];
  currentPlayer: string;
  gamePhase: 'waiting' | 'playing' | 'finished';
  dice: Dice[];
  rollsRemaining: number;
  scoreCards: Record<string, ScoreCard>;
  winner: string | null;
}

interface GameActions {
  rollDice: () => void;
  holdDie: (index: number) => void;
  scoreCategory: (category: string) => void;
  endTurn: () => void;
  joinGame: (gameId: string) => void;
  leaveGame: () => void;
}
```

### User Context
```typescript
interface UserState {
  user: User | null;
  isAuthenticated: boolean;
  loading: boolean;
  error: string | null;
}

interface UserActions {
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (userData: RegisterData) => Promise<void>;
  logout: () => void;
  updateProfile: (updates: ProfileUpdates) => Promise<void>;
}
```

## Custom Hooks

### useGame
- Manages game state and actions
- Handles Socket.IO events
- Provides game-related utilities

### useAuth
- Manages authentication state
- Handles token persistence
- Provides auth utilities

### useDice
- Manages dice rolling logic
- Handles hold/unhold functionality
- Provides dice animations

### useScoreCard
- Calculates possible scores
- Manages scoring logic
- Validates score selections

## Services

### API Service
```typescript
class ApiService {
  private baseURL: string;
  private authToken: string | null;

  // Authentication
  login(credentials: LoginCredentials): Promise<AuthResponse>;
  register(userData: RegisterData): Promise<AuthResponse>;
  refreshToken(): Promise<AuthResponse>;

  // Game Management
  createGame(options: GameOptions): Promise<Game>;
  joinGame(gameId: string): Promise<Game>;
  getGame(gameId: string): Promise<Game>;
  getGameHistory(): Promise<Game[]>;

  // User Management
  getProfile(): Promise<User>;
  updateProfile(updates: ProfileUpdates): Promise<User>;
  getStats(): Promise<UserStats>;
}
```

### Socket Service
```typescript
class SocketService {
  private socket: Socket;

  connect(): void;
  disconnect(): void;
  
  // Game Events
  onGameStateUpdate(callback: (gameState: GameState) => void): void;
  onPlayerJoined(callback: (player: Player) => void): void;
  onPlayerLeft(callback: (playerId: string) => void): void;
  onTurnChange(callback: (playerId: string) => void): void;
  onGameEnd(callback: (winner: string) => void): void;

  // Emit Events
  rollDice(): void;
  holdDice(indices: number[]): void;
  scoreCategory(category: string): void;
  endTurn(): void;
}
```

## Styling Guidelines

### Tailwind Configuration
- Custom color palette for Yahtzee theme
- Responsive breakpoints
- Custom animations for dice rolling
- Dark/light mode support

### Component Styling
- Consistent spacing using Tailwind scale
- Hover and focus states
- Mobile-first responsive design
- Accessibility considerations

## Responsive Design

### Breakpoints
- **Mobile**: 320px - 767px
- **Tablet**: 768px - 1023px  
- **Desktop**: 1024px+

### Mobile Optimizations
- Touch-friendly dice interaction
- Collapsible sidebar
- Simplified score card layout
- Gesture support for dice rolling

## Accessibility Features
- ARIA labels for game elements
- Keyboard navigation support
- Screen reader announcements
- High contrast mode
- Focus management

## Performance Optimizations
- Code splitting by routes
- Lazy loading for non-critical components
- Memoization for expensive calculations
- Virtual scrolling for large lists
- Image optimization

## Testing Strategy

### Unit Tests
- Component rendering
- Hook behavior
- Utility functions
- State management

### Integration Tests
- API service methods
- Socket event handling
- Context providers
- User workflows

### E2E Tests
- Complete game flow
- Authentication process
- Multiplayer scenarios
- Cross-browser testing

## Build and Deployment

### Development
```bash
npm run dev          # Start development server
npm run test         # Run tests
npm run lint         # Lint code
npm run type-check   # TypeScript checking
```

### Production
```bash
npm run build        # Build for production
npm run preview      # Preview production build
npm run analyze      # Bundle analysis
```

### Environment Variables
```
VITE_API_URL=http://localhost:5000
VITE_SOCKET_URL=http://localhost:5000
VITE_ENV=development
```

## Browser Support
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Security Considerations
- XSS prevention
- CSRF protection
- Input sanitization
- Secure token storage
- Content Security Policy