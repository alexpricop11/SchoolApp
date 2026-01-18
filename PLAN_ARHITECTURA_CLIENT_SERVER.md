# Plan Arhitectură Client-Server pentru SchoolApp

**Data:** 2026-01-19
**Versiune:** 1.0

---

## 📋 Cuprins

1. [Analiza Situației Actuale](#1-analiza-situației-actuale)
2. [Arhitectura Țintă](#2-arhitectura-țintă)
3. [Plan de Implementare - Client](#3-plan-de-implementare---client)
4. [Plan de Implementare - Admin](#4-plan-de-implementare---admin)
5. [Plan de Implementare - Server](#5-plan-de-implementare---server)
6. [Prioritizare și Etape](#6-prioritizare-și-etape)
7. [Considerații Tehnice](#7-considerații-tehnice)

---

## 1. Analiza Situației Actuale

### 1.1 CLIENT (Flutter) - `client/`

#### ✅ CE EXISTĂ DEJA (Implementat):

**Caching Local (Hive):**
- ✅ `CacheService` implementat cu 8 boxuri pentru date offline
- ✅ Cache pentru: grades, schedule, homework, notifications, attendance, materials, student info, metadata
- ✅ Timestamp tracking pentru invalidare cache (default: 15 min)
- ✅ Fallback la cache când API eșuează (vezi `student_data_api.dart`)
- ✅ Force refresh capability (`forceRefresh` parameter)

**Comunicare Server:**
- ✅ `DioClient` cu interceptori pentru token management
- ✅ Auto token refresh mechanism
- ✅ JWT authentication (access + refresh tokens)
- ✅ WebSocket support (`web_socket_channel`)
- ✅ Secure storage pentru tokens (`flutter_secure_storage`)

**Structură Clean Architecture:**
- ✅ Domain layer (entities, repositories, use cases)
- ✅ Data layer (models, data sources, repository implementations)
- ✅ Presentation layer (controllers, pages, widgets)
- ✅ Dependency injection cu GetIt

#### ❌ CE LIPSEȘTE (Trebuie Implementat):

**Offline-First Capabilities:**
- ❌ **Write operations queue** - Nu există mecanisme pentru a stoca modificările făcute offline
- ❌ **Sync engine** - Nu există sincronizare automată când conexiunea revine
- ❌ **Conflict resolution** - Nu există strategie pentru conflicte de date
- ❌ **Optimistic updates** - UI nu se actualizează instant la modificări
- ❌ **Background sync** - Nu există sincronizare în fundal

**Cache Management:**
- ❌ **Partial cache** - Cache-ul este doar pentru citire (read-only)
- ❌ **Delta sync** - Nu se sincronizează doar modificările
- ❌ **Cache versioning** - Nu există versiuni pentru invalidarea globală
- ❌ **Selective caching** - Nu există prioritizare cache (ce e important)

**Network Layer:**
- ❌ **Connectivity monitoring** - Nu există detectare activă a conexiunii
- ❌ **Request queueing** - Cereri eșuate nu sunt re-trimise automat
- ❌ **Retry logic** - Nu există strategie de retry cu exponential backoff
- ❌ **Network status indicator** - UI nu arată starea conexiunii

---

### 1.2 ADMIN (Flutter) - `admin_school_app/`

#### ✅ CE EXISTĂ DEJA:

**Comunicare Server:**
- ✅ `Dio` client pentru API calls
- ✅ JWT authentication
- ✅ Secure storage pentru tokens
- ✅ Clean architecture (domain/data/presentation layers)

**Funcționalități CRUD:**
- ✅ Management complet pentru: Schools, Classes, Teachers, Students, Admin Users
- ✅ Dashboard cu statistici
- ✅ Data sources pentru toate entitățile

#### ❌ CE LIPSEȘTE COMPLET:

**Acces Direct Baza de Date:**
- ❌ **Database driver** - Nu există PostgreSQL/SQLite driver Flutter
- ❌ **Connection manager** - Nu există gestiune conexiune directă
- ❌ **Repository dual-mode** - Nu poate alege între API/DB direct
- ❌ **Migration support** - Nu poate gestiona schema DB direct

**Offline/Caching:**
- ❌ **Local cache** - Zero caching implementat
- ❌ **Offline fallback** - Nu funcționează fără server
- ❌ **Data persistence** - Nu stochează nimic local

**Dual Mode Architecture:**
- ❌ **Mode switcher** - Nu poate comuta între server/direct DB
- ❌ **Auto-detection** - Nu detectează dacă serverul e disponibil
- ❌ **Fallback mechanism** - Nu are plan B când serverul cade

---

### 1.3 SERVER (Python/FastAPI) - `server/`

#### ✅ CE EXISTĂ DEJA:

**API RESTful:**
- ✅ FastAPI cu toate endpoint-urile CRUD
- ✅ Autentificare JWT (access + refresh tokens)
- ✅ PostgreSQL + SQLAlchemy (async)
- ✅ Alembic pentru migrări
- ✅ WebSocket support pentru real-time updates
- ✅ CORS middleware
- ✅ File upload support

**Structură Modulară:**
- ✅ Module separate: auth, users, schools, classes, grades, attendance, homework, schedule, materials, notifications
- ✅ Repository pattern
- ✅ Service layer
- ✅ Schema validation cu Pydantic

#### ❌ CE LIPSEȘTE:

**Sync & Offline Support:**
- ❌ **Sync API endpoints** - Nu există endpoint-uri pentru batch sync
- ❌ **Conflict resolution** - Nu există server-side conflict handling
- ❌ **Last-modified tracking** - Nu toate entitățile au timestamp-uri
- ❌ **Delta API** - Nu poate returna doar modificările de la un timestamp
- ❌ **Tombstone records** - Nu există înregistrări pentru date șterse

**Admin Direct Access:**
- ❌ **Admin authentication layer** - Nu există validare specială pentru admin direct
- ❌ **DB connection pooling** - Nu e optimizat pentru conexiuni directe multiple
- ❌ **Read-only mode** - Nu poate intra în read-only când admin accesează direct

---

## 2. Arhitectura Țintă

### 2.1 CLIENT - Offline-First Architecture

```
┌─────────────────────────────────────────────┐
│           PRESENTATION LAYER                │
│  (Controllers, Pages, Widgets, GetX State) │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│           DOMAIN LAYER                      │
│  (Use Cases, Entities, Repository Interfaces)│
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│         DATA LAYER (SMART SYNC)             │
├─────────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐   │
│  │   SYNC ENGINE (NEW)                 │   │
│  │  - Connectivity Monitor             │   │
│  │  - Conflict Resolver                │   │
│  │  - Delta Sync Logic                 │   │
│  │  - Background Worker                │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌──────────────┐      ┌─────────────────┐ │
│  │  Repository  │◄────►│  Sync Manager   │ │
│  │ Implementation│      │  - Queue Ops    │ │
│  └──────┬───────┘      │  - Retry Logic  │ │
│         │              └─────────────────┘ │
│         │                                  │
│  ┌──────▼────────┐    ┌─────────────────┐ │
│  │ Remote Source │    │  Local Source   │ │
│  │  (Dio/HTTP)   │    │  (Hive Cache)   │ │
│  └───────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────┘
```

**Flow Offline-First:**
1. UI cere date → Repository
2. Repository verifică cache local
3. Dacă cache valid → returnează imediat
4. În background, sincronizează cu serverul
5. Update cache + UI reactiv

**Write Operations:**
1. Write local în cache
2. Add to sync queue
3. Update UI (optimistic)
4. Background sync la server
5. Handle conflicts dacă apar

---

### 2.2 ADMIN - Dual Mode Architecture

```
┌─────────────────────────────────────────────┐
│           ADMIN PRESENTATION                │
└─────────────────┬───────────────────────────┘
                  │
┌─────────────────▼───────────────────────────┐
│        CONNECTION MODE SWITCHER             │
│  ┌─────────────┐  ┌────────────────────┐   │
│  │ Auto Detect │  │ Manual Toggle      │   │
│  │ Server Up?  │  │ Server/Direct Mode │   │
│  └─────────────┘  └────────────────────┘   │
└─────────────────┬───────────────────────────┘
                  │
        ┌─────────▼──────────┐
        │                    │
┌───────▼──────┐    ┌───────▼──────────┐
│ SERVER MODE  │    │  DIRECT DB MODE  │
│              │    │                  │
│ Dio HTTP     │    │ PostgreSQL       │
│ + REST API   │    │ Direct Driver    │
│              │    │                  │
│ (Preferred)  │    │ (Fallback)       │
└──────────────┘    └──────────────────┘
```

**Strategie:**
- **Default:** Server Mode (mai sigur, audit trail, validare)
- **Fallback:** Direct DB Mode (când server down)
- **Manual:** Admin poate forța un mod specific
- **Read-Only în Direct:** Pentru siguranță, direct DB mode poate fi read-only

---

### 2.3 SERVER - Sync-Ready API

**Endpoint-uri Noi pentru Sync:**

```python
# Sync endpoints
GET  /api/sync/delta?since=timestamp&entities=grades,homework
POST /api/sync/batch (multiple operations)
POST /api/sync/resolve-conflicts
GET  /api/sync/status

# Response format:
{
  "timestamp": "2026-01-19T12:00:00Z",
  "changes": {
    "grades": {
      "created": [...],
      "updated": [...],
      "deleted": [...]  # tombstone records
    }
  },
  "conflicts": [...]
}
```

---

## 3. Plan de Implementare - CLIENT

### 3.1 Connectivity Manager

**Locație:** `client/lib/core/network/connectivity_manager.dart`

**Funcționalități:**
```dart
class ConnectivityManager {
  // Stream pentru status conexiune
  Stream<ConnectivityStatus> get statusStream;

  // Check actual conexiune (nu doar WiFi on/off)
  Future<bool> hasInternetConnection();

  // Retry ping către server
  Future<bool> isServerReachable();

  // Listeners pentru schimbare status
  void addListener(Function(ConnectivityStatus) callback);
}

enum ConnectivityStatus {
  online,
  offline,
  unstable
}
```

**Dependențe noi:**
- `connectivity_plus: ^6.0.0` - detectare tip conexiune
- `internet_connection_checker: ^2.0.0` - verificare efectivă internet

---

### 3.2 Sync Engine

**Locație:** `client/lib/core/sync/`

**Componente:**

#### A. Operation Queue (`sync_queue.dart`)
```dart
class SyncQueue {
  // Add operațiune la coadă
  Future<void> enqueue(SyncOperation operation);

  // Procesare coadă
  Future<void> processQueue();

  // Clear după sync reușit
  Future<void> clearCompleted();

  // Retry failed operations
  Future<void> retryFailed();
}

class SyncOperation {
  String id;
  OperationType type; // CREATE, UPDATE, DELETE
  String entity;      // "grade", "homework", etc.
  Map<String, dynamic> data;
  int retryCount;
  DateTime timestamp;
  SyncStatus status;
}
```

**Stocare:** Hive box `sync_queue_box`

#### B. Conflict Resolver (`conflict_resolver.dart`)
```dart
class ConflictResolver {
  // Strategii de rezolvare
  Future<T> resolve<T>(
    T localVersion,
    T serverVersion,
    ConflictStrategy strategy,
  );
}

enum ConflictStrategy {
  serverWins,      // Default - serverul are prioritate
  clientWins,      // Client override (rare)
  lastWriteWins,   // Pe bază de timestamp
  manual,          // User decision - arată dialog
}
```

#### C. Sync Manager (`sync_manager.dart`)
```dart
class SyncManager {
  // Start sync automat
  Future<void> startPeriodicSync({Duration interval = const Duration(minutes: 5)});

  // Sync manual (pull to refresh)
  Future<SyncResult> syncNow({List<String>? entities});

  // Delta sync - doar modificările
  Future<void> syncDelta({required DateTime since});

  // Upload pending changes
  Future<void> uploadPendingChanges();
}
```

---

### 3.3 Enhanced Cache Service

**Modificări la:** `client/lib/core/services/cache_service.dart`

**Funcționalități noi:**

```dart
class CacheService {
  // ... existing methods ...

  // WRITE operations (NEW)
  static Future<void> saveForSync<T>(
    String boxName,
    String key,
    T data,
    {required SyncStatus status}
  );

  // Versioning (NEW)
  static Future<void> setCacheVersion(int version);
  static int? getCacheVersion();

  // Dirty flag pentru date modificate (NEW)
  static Future<void> markDirty(String boxName, String key);
  static List<String> getDirtyKeys(String boxName);

  // Timestamp comparison (NEW)
  static bool isNewerThan(String key, DateTime serverTimestamp);
}
```

---

### 3.4 Repository Pattern Update

**Exemplu:** `student_repository_impl.dart`

**Înainte (actual):**
```dart
Future<List<Grade>> getGrades() async {
  try {
    return await remoteDataSource.getGrades();
  } catch (e) {
    return localDataSource.getCachedGrades() ?? [];
  }
}
```

**După (offline-first):**
```dart
Future<List<Grade>> getGrades({bool forceRefresh = false}) async {
  // 1. Return cache imediat
  final cached = await localDataSource.getGrades();

  // 2. În background, sync cu server
  if (connectivityManager.isOnline || forceRefresh) {
    unawaited(_syncGrades());
  }

  return cached ?? [];
}

Future<void> _syncGrades() async {
  try {
    final serverData = await remoteDataSource.getGrades();
    await localDataSource.saveGrades(serverData);
    // Notify UI prin Stream/GetX
    gradesController.update(serverData);
  } catch (e) {
    // Log error, retry later
  }
}

// Write operation cu queue
Future<void> createGrade(Grade grade) async {
  // 1. Save local imediat (optimistic update)
  await localDataSource.saveGrade(grade);

  // 2. Update UI
  gradesController.add(grade);

  // 3. Queue pentru server sync
  await syncQueue.enqueue(
    SyncOperation(
      type: OperationType.CREATE,
      entity: 'grade',
      data: grade.toJson(),
    ),
  );

  // 4. Background sync
  if (connectivityManager.isOnline) {
    unawaited(syncManager.uploadPendingChanges());
  }
}
```

---

### 3.5 UI/UX Indicators

**Componente noi:**

#### A. Connection Status Bar
```dart
// Widget pentru status conexiune
class ConnectionStatusBar extends StatelessWidget {
  // Arată banner când offline
  // Arată "Syncing..." când sincronizează
  // Arată număr operațiuni în așteptare
}
```

#### B. Sync Button
```dart
// Pull-to-refresh enhanced
class SyncRefreshIndicator extends StatelessWidget {
  // Arată când a fost ultima sincronizare
  // Force sync manual
  // Progress indicator pentru sync
}
```

---

## 4. Plan de Implementare - ADMIN

### 4.1 Database Direct Access Layer

**Dependențe noi:**
```yaml
dependencies:
  postgres: ^3.0.0  # PostgreSQL driver pentru Flutter/Dart
  sqflite: ^2.3.0   # SQLite pentru fallback local
```

**Locație:** `admin_school_app/lib/core/database/`

**Componente:**

#### A. Database Connection Manager
```dart
class DatabaseConnectionManager {
  PostgreSQLConnection? _pgConnection;

  // Connect direct la PostgreSQL
  Future<bool> connectToPostgres({
    required String host,
    required int port,
    required String database,
    required String username,
    required String password,
  });

  // Check conexiune
  Future<bool> isConnected();

  // Disconnect
  Future<void> disconnect();

  // Execute query
  Future<List<Map<String, dynamic>>> query(String sql, [List<dynamic>? params]);

  // Execute write (cu transaction)
  Future<int> execute(String sql, [List<dynamic>? params]);
}
```

#### B. Mode Switcher
```dart
class ConnectionModeManager {
  ConnectionMode _currentMode = ConnectionMode.server;

  // Auto-detect best mode
  Future<ConnectionMode> detectBestMode();

  // Switch manual
  Future<void> switchTo(ConnectionMode mode);

  // Get current mode
  ConnectionMode get currentMode;

  // Listeners
  Stream<ConnectionMode> get modeStream;
}

enum ConnectionMode {
  server,    // Preferred - via REST API
  directDb,  // Fallback - direct PostgreSQL
  offline,   // Read-only local cache
}
```

---

### 4.2 Dual Repository Implementation

**Exemplu:** `school_repository_impl.dart`

```dart
class SchoolRepositoryImpl implements SchoolRepository {
  final SchoolRemoteDataSource remoteDataSource;  // Dio/HTTP
  final SchoolDatabaseDataSource dbDataSource;    // PostgreSQL direct
  final ConnectionModeManager modeManager;

  @override
  Future<List<School>> getSchools() async {
    switch (modeManager.currentMode) {
      case ConnectionMode.server:
        return await _getSchoolsFromServer();

      case ConnectionMode.directDb:
        return await _getSchoolsFromDatabase();

      case ConnectionMode.offline:
        return await _getSchoolsFromCache();
    }
  }

  Future<List<School>> _getSchoolsFromServer() async {
    try {
      return await remoteDataSource.getSchools();
    } catch (e) {
      // Fallback la DB direct
      if (await dbDataSource.canConnect()) {
        await modeManager.switchTo(ConnectionMode.directDb);
        return await _getSchoolsFromDatabase();
      }
      rethrow;
    }
  }

  Future<List<School>> _getSchoolsFromDatabase() async {
    final results = await dbDataSource.query(
      'SELECT * FROM schools ORDER BY name'
    );
    return results.map((row) => School.fromDbRow(row)).toList();
  }
}
```

---

### 4.3 Database Data Sources

**Locație:** `admin_school_app/lib/data/data_sources/database/`

**Pentru fiecare entitate (school, teacher, student, etc.):**

```dart
class SchoolDatabaseDataSource {
  final DatabaseConnectionManager dbManager;

  Future<List<Map<String, dynamic>>> getSchools() async {
    return await dbManager.query('SELECT * FROM schools');
  }

  Future<Map<String, dynamic>?> getSchool(String id) async {
    final results = await dbManager.query(
      'SELECT * FROM schools WHERE id = $1',
      [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> createSchool(SchoolModel school) async {
    final result = await dbManager.execute(
      '''INSERT INTO schools (id, name, address, phone, email, created_at)
         VALUES ($1, $2, $3, $4, $5, $6)''',
      [
        school.id,
        school.name,
        school.address,
        school.phone,
        school.email,
        DateTime.now(),
      ],
    );
    return result > 0;
  }

  // Similar pentru update, delete
}
```

---

### 4.4 Settings & Configuration

**UI pentru configurare:**

```dart
class AdminSettingsPage extends StatelessWidget {
  // Connection Mode Section
  - Toggle: Server Mode / Direct DB Mode / Auto
  - Server URL input
  - Test Connection button

  // Database Configuration (pentru Direct Mode)
  - Host
  - Port
  - Database Name
  - Username
  - Password (secure)
  - Test DB Connection button

  // Security
  - Enable Read-Only Mode (pentru Direct DB)
  - Require 2FA for Direct DB access
}
```

**Stocare configurație:**
```dart
class AdminConfig {
  static const String serverUrl = 'http://10.240.0.129:8000';
  static const String dbHost = '10.240.0.129';
  static const int dbPort = 5432;
  static const String dbName = 'school_db';
  // Username/password în secure storage
}
```

---

### 4.5 Local Cache pentru Admin

**Adăugare Hive:**

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

**Cache simplu pentru:**
- Dashboard statistics (cache 5 min)
- Recent accessed entities
- User preferences

**Nu trebuie cache complex ca la client** - admin lucrează mai mult cu date fresh.

---

## 5. Plan de Implementare - SERVER

### 5.1 Sync API Endpoints

**Locație:** `server/app/sync/`

**Endpoint-uri noi:**

#### A. Delta Sync Endpoint
```python
# routes.py
@router.get("/sync/delta")
async def get_delta_changes(
    since: datetime,
    entities: Optional[List[str]] = Query(None),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Returnează doar modificările de la timestamp-ul dat.
    """
    changes = await sync_service.get_changes_since(
        db, since, entities, current_user
    )
    return {
        "timestamp": datetime.utcnow(),
        "changes": changes
    }
```

#### B. Batch Operations
```python
@router.post("/sync/batch")
async def batch_operations(
    operations: List[SyncOperation],
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Procesare multiple operațiuni într-o singură cerere.
    """
    results = await sync_service.process_batch(
        db, operations, current_user
    )
    return results
```

#### C. Conflict Resolution
```python
@router.post("/sync/resolve-conflicts")
async def resolve_conflicts(
    conflicts: List[ConflictData],
    strategy: ConflictStrategy,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Rezolvare conflicte cu strategia aleasă.
    """
    resolved = await sync_service.resolve_conflicts(
        db, conflicts, strategy, current_user
    )
    return resolved
```

---

### 5.2 Timestamp Tracking

**Modificări la modele:**

```python
# Adăugare la TOATE modelele
class BaseModel(Base):
    __abstract__ = True

    id = Column(String, primary_key=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime, nullable=True)  # Soft delete pentru tombstones
    version = Column(Integer, default=1)  # Optimistic locking
```

**Migration Alembic:**
```bash
alembic revision -m "add_sync_timestamps"
```

---

### 5.3 Tombstone Records

**Pentru delete operations:**

```python
class SyncService:
    async def soft_delete(self, db: AsyncSession, entity_type: str, entity_id: str):
        """
        Soft delete - marchează deleted_at în loc să șteargă.
        Clientul va ști să șteargă local.
        """
        query = text(f"""
            UPDATE {entity_type}
            SET deleted_at = :now, updated_at = :now
            WHERE id = :id
        """)
        await db.execute(query, {
            "now": datetime.utcnow(),
            "id": entity_id
        })
        await db.commit()
```

---

### 5.4 Admin Direct Access Security

**Middleware pentru detectare acces direct:**

```python
# middleware/admin_direct_access.py
async def log_direct_db_access(request: Request, call_next):
    """
    Detectează când adminul accesează direct DB (fără API).
    """
    # Check dacă cererea vine de la admin app în direct mode
    admin_direct = request.headers.get("X-Admin-Direct-Mode")

    if admin_direct:
        # Log access pentru audit
        logger.warning(f"Direct DB access from admin: {request.url}")

        # Optional: Block anumite operații
        if request.method in ["POST", "PUT", "DELETE"]:
            if not settings.ALLOW_ADMIN_DIRECT_WRITES:
                raise HTTPException(
                    status_code=403,
                    detail="Direct write operations disabled"
                )

    response = await call_next(request)
    return response
```

**Settings:**
```python
# config/settings.py
ALLOW_ADMIN_DIRECT_WRITES = False  # Read-only by default pentru siguranță
```

---

### 5.5 Connection Pooling Optimization

**Pentru suport admin direct + API simultan:**

```python
# database.py
from sqlalchemy.pool import NullPool, QueuePool

# Pentru production
engine = create_async_engine(
    DATABASE_URL,
    echo=False,
    pool_size=20,          # Increased pentru admin direct
    max_overflow=40,       # Extra connections
    pool_pre_ping=True,    # Test connection înainte de use
    pool_recycle=3600,     # Recycle la 1h
)
```

---

## 6. Prioritizare și Etape

### Faza 1: CLIENT Offline-First (Prioritate: ⭐⭐⭐ MARE)

**Durata estimată:** 3-4 săptămâni

**Taskuri:**

#### Săptămâna 1: Infrastructure
- [ ] Implementare `ConnectivityManager`
- [ ] Setup `connectivity_plus` + testing
- [ ] Implementare `SyncQueue` (Hive storage)
- [ ] Unit tests pentru queue operations

#### Săptămâna 2: Sync Engine Core
- [ ] Implementare `SyncManager` (upload/download)
- [ ] Implementare `ConflictResolver` (server wins strategy)
- [ ] Background sync cu WorkManager/similar
- [ ] Integration tests pentru sync flow

#### Săptămâna 3: Repository Updates
- [ ] Refactor `StudentDataApi` pentru offline-first
- [ ] Update repository implementations
- [ ] Implementare optimistic updates
- [ ] Add write operations la queue

#### Săptămâna 4: UI/UX & Testing
- [ ] Implementare `ConnectionStatusBar`
- [ ] Enhanced pull-to-refresh cu sync info
- [ ] E2E testing (offline → online transitions)
- [ ] Bug fixes & optimizations

**Criterii de succes:**
- ✅ App funcționează complet offline pentru citire
- ✅ Modificările offline se sincronizează automat
- ✅ UI arată clar status conexiune & sync
- ✅ Nu se pierd date la conexiune instabilă

---

### Faza 2: SERVER Sync API (Prioritate: ⭐⭐⭐ MARE)

**Durata estimată:** 2 săptămâni

**Taskuri:**

#### Săptămâna 1: Database & Models
- [ ] Migration Alembic pentru timestamps (created_at, updated_at, deleted_at)
- [ ] Update toate modelele cu BaseModel
- [ ] Implementare soft delete
- [ ] Testing migrations pe dev DB

#### Săptămâna 2: Sync Endpoints
- [ ] Implementare `/sync/delta` endpoint
- [ ] Implementare `/sync/batch` endpoint
- [ ] Implementare conflict resolution API
- [ ] API documentation (Swagger)
- [ ] Integration tests

**Criterii de succes:**
- ✅ Toate tabelele au timestamps
- ✅ Soft delete funcționează (tombstones)
- ✅ Delta sync returnează doar modificări
- ✅ Batch operations procesează corect

---

### Faza 3: ADMIN Dual Mode (Prioritate: ⭐⭐ MEDIE)

**Durata estimată:** 3 săptămâni

**Taskuri:**

#### Săptămâna 1: Database Layer
- [ ] Setup `postgres` package pentru Flutter
- [ ] Implementare `DatabaseConnectionManager`
- [ ] Implementare `ConnectionModeManager`
- [ ] Testing conexiune PostgreSQL

#### Săptămâna 2: Database Data Sources
- [ ] Implementare DB data sources pentru toate entitățile
- [ ] SQL queries pentru CRUD operations
- [ ] Transaction handling
- [ ] Error handling & logging

#### Săptămâna 3: Repository Dual Mode
- [ ] Refactor repository implementations
- [ ] Auto-fallback logic (server → DB direct)
- [ ] Settings page pentru configurare
- [ ] Testing switch între moduri

**Criterii de succes:**
- ✅ Admin poate conecta direct la PostgreSQL
- ✅ Auto-switch când serverul cade
- ✅ Toate operațiunile funcționează în ambele moduri
- ✅ Configurare ușoară prin UI

---

### Faza 4: ADMIN Local Cache (Prioritate: ⭐ MICĂ)

**Durata estimată:** 1 săptămână

**Taskuri:**
- [ ] Setup Hive pentru admin app
- [ ] Cache pentru dashboard stats
- [ ] Cache pentru recent entities
- [ ] Cache expiry logic

**Criterii de succes:**
- ✅ Dashboard se încarcă instant din cache
- ✅ Cache se invalidează corespunzător

---

### Faza 5: Security & Hardening (Prioritate: ⭐⭐ MEDIE)

**Durata estimată:** 1 săptămână

**Taskuri:**
- [ ] Middleware pentru log admin direct access
- [ ] Implementare read-only mode pentru admin direct
- [ ] Encryption pentru DB credentials în admin
- [ ] Audit logging pentru operațiuni critice
- [ ] Security testing

**Criterii de succes:**
- ✅ Toate accesele direct DB sunt logate
- ✅ Credentials stocate securizat
- ✅ Read-only mode funcționează

---

## 7. Considerații Tehnice

### 7.1 Performanță

**CLIENT:**
- **Lazy loading:** Nu încărca tot cache-ul odată
- **Pagination:** Pentru liste mari (grades, homework)
- **Debouncing:** Pentru sync triggers (nu la fiecare scroll)
- **Background isolates:** Sync fără să blocheze UI

**ADMIN:**
- **Connection pooling:** Reuse conexiuni DB
- **Query optimization:** Index-uri corecte în PostgreSQL
- **Batch operations:** Multiple queries într-o transaction

**SERVER:**
- **Pagination pe delta sync:** Nu returna 10k înregistrări odată
- **Compression:** Gzip pentru responses mari
- **Caching layer:** Redis pentru queries frecvente

---

### 7.2 Securitate

**CLIENT:**
- ⚠️ **Nu stoca parole în cache Hive** (doar tokens JWT)
- ⚠️ **Encrypt Hive boxes** cu AES (Hive encryption)
- ⚠️ **Validate data** înainte de sync la server

**ADMIN:**
- ⚠️ **DB credentials în secure storage** (flutter_secure_storage)
- ⚠️ **SSL/TLS pentru PostgreSQL connection**
- ⚠️ **Limited permissions** pentru admin DB user (read-only recommanded)
- ⚠️ **2FA obligatoriu** pentru direct DB mode

**SERVER:**
- ⚠️ **Rate limiting** pe sync endpoints
- ⚠️ **Audit log** pentru toate admin operations
- ⚠️ **SQL injection prevention** (folosește parametrizat queries)

---

### 7.3 Testare

**Unit Tests:**
- Sync queue operations
- Conflict resolution logic
- Repository dual mode switching
- Cache management

**Integration Tests:**
- Client offline → online sync flow
- Admin server → direct DB fallback
- Concurrent writes conflict handling

**E2E Tests:**
- Scenarii offline complete (airplane mode)
- Server downtime recovery
- Multi-device sync

---

### 7.4 Monitoring & Debugging

**Logging:**
```dart
// Client
class SyncLogger {
  static void logSyncStart();
  static void logSyncSuccess(int itemsSynced);
  static void logSyncError(dynamic error);
  static void logConflict(ConflictData conflict);
}
```

**Metrics:**
- Sync success rate
- Average sync duration
- Queue size over time
- Conflict frequency
- Network error rate

**Debug UI:**
- Sync history (last 50 syncs)
- Queue viewer (pending operations)
- Cache browser (inspect local data)
- Force clear cache button

---

## 8. Diagrame Flux

### 8.1 CLIENT - Write Operation Flow

```
┌─────────────────┐
│  User Action    │
│  (Create Grade) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 1. Save Local   │◄─── Optimistic Update
│    (Hive Cache) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 2. Update UI    │◄─── GetX reactive
│    (Immediate)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ 3. Add to Queue │
│   (SyncQueue)   │
└────────┬────────┘
         │
         ▼
    ┌────┴────┐
    │ Online? │
    └────┬────┘
         │
    ┌────┴────┐
   YES        NO
    │          │
    ▼          ▼
┌────────┐  ┌──────────┐
│4. Sync │  │ Wait for │
│  Now   │  │  Online  │
└───┬────┘  └──────────┘
    │
    ▼
┌─────────────────┐
│ 5. POST /api    │
└────────┬────────┘
         │
    ┌────┴────┐
    │Success? │
    └────┬────┘
         │
    ┌────┴────┐
   YES        NO
    │          │
    ▼          ▼
┌────────┐  ┌──────────┐
│Remove  │  │ Retry    │
│Queue   │  │ Later    │
└────────┘  └──────────┘
```

---

### 8.2 ADMIN - Mode Switching Flow

```
┌─────────────────┐
│  App Startup    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Load Settings   │
│ (Preferred Mode)│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Detect Server   │
│ (HTTP ping)     │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Server  │
    │   Up?   │
    └────┬────┘
         │
    ┌────┴────┐
   YES        NO
    │          │
    ▼          ▼
┌─────────┐ ┌──────────┐
│ SERVER  │ │  Check   │
│  MODE   │ │  DB      │
└─────────┘ └────┬─────┘
                 │
            ┌────┴────┐
            │DB Conn? │
            └────┬────┘
                 │
            ┌────┴────┐
           YES        NO
            │          │
            ▼          ▼
       ┌─────────┐ ┌──────────┐
       │ DIRECT  │ │ OFFLINE  │
       │DB MODE  │ │  MODE    │
       └─────────┘ └──────────┘

// Runtime Switch (când server cade)
┌─────────────────┐
│ API Call Failed │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Try DB Direct   │
└────────┬────────┘
         │
    ┌────┴────┐
    │Success? │
    └────┬────┘
         │
    ┌────┴────┐
   YES        NO
    │          │
    ▼          ▼
┌─────────┐ ┌──────────┐
│ Switch  │ │  Show    │
│ to DB   │ │  Error   │
└─────────┘ └──────────┘
```

---

## 9. Configurare Inițială

### 9.1 CLIENT - Dependențe noi

**Adăugare în `client/pubspec.yaml`:**

```yaml
dependencies:
  # Existing...

  # Connectivity & Network
  connectivity_plus: ^6.0.0
  internet_connection_checker: ^2.0.0

  # Background tasks
  workmanager: ^0.5.2  # Pentru Android/iOS background sync

  # Encryption
  encrypt: ^5.0.3  # Pentru Hive encryption
```

### 9.2 ADMIN - Dependențe noi

**Adăugare în `admin_school_app/pubspec.yaml`:**

```yaml
dependencies:
  # Existing...

  # Database direct access
  postgres: ^3.0.0

  # Local cache
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

### 9.3 SERVER - Dependințe noi

**Adăugare în `server/requirements.txt`:**

```txt
# Existing...

# Monitoring & Logging (optional dar recomandat)
prometheus-fastapi-instrumentator==7.0.0
python-json-logger==2.0.7

# Rate limiting
slowapi==0.1.9
```

---

## 10. Checklist Finală

### CLIENT - Offline-First
- [ ] ConnectivityManager implementat
- [ ] SyncQueue cu Hive storage
- [ ] SyncManager cu upload/download
- [ ] ConflictResolver (server wins)
- [ ] Repository pattern updated
- [ ] Cache service enhanced
- [ ] UI indicators (status bar, sync button)
- [ ] Background sync worker
- [ ] Write operations queue
- [ ] Optimistic UI updates
- [ ] Tests (unit + integration + E2E)

### ADMIN - Dual Mode
- [ ] DatabaseConnectionManager
- [ ] ConnectionModeManager
- [ ] Database data sources (toate entitățile)
- [ ] Repository dual implementation
- [ ] Auto-fallback logic
- [ ] Settings UI pentru configurare
- [ ] Secure storage pentru DB credentials
- [ ] Hive cache pentru dashboard
- [ ] Read-only mode toggle
- [ ] Tests (connection, fallback, queries)

### SERVER - Sync API
- [ ] Migration timestamps (created_at, updated_at, deleted_at)
- [ ] Soft delete implementation
- [ ] `/sync/delta` endpoint
- [ ] `/sync/batch` endpoint
- [ ] Conflict resolution API
- [ ] Admin access middleware
- [ ] Connection pooling optimization
- [ ] API documentation
- [ ] Tests (sync endpoints, conflicts)

### SECURITY
- [ ] Hive encryption (client)
- [ ] DB credentials encryption (admin)
- [ ] SSL/TLS PostgreSQL (admin)
- [ ] Rate limiting (server)
- [ ] Audit logging (server)
- [ ] 2FA pentru admin direct mode
- [ ] Security audit complete

### MONITORING
- [ ] Sync metrics logging
- [ ] Error tracking
- [ ] Performance monitoring
- [ ] Debug UI pentru sync
- [ ] Alerting pentru sync failures

---

## 11. Resurse & Referințe

**Flutter Offline-First:**
- [Hive Documentation](https://docs.hivedb.dev/)
- [Offline-First Architecture](https://developer.android.com/topic/architecture/data-layer/offline-first)
- [Flutter Connectivity Plus](https://pub.dev/packages/connectivity_plus)

**PostgreSQL Direct Access:**
- [postgres package](https://pub.dev/packages/postgres)
- [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/security.html)

**FastAPI Sync Patterns:**
- [FastAPI Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/)
- [SQLAlchemy Async](https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html)

**Conflict Resolution:**
- [CRDTs Explained](https://crdt.tech/)
- [Operational Transformation](https://en.wikipedia.org/wiki/Operational_transformation)

---

## 12. Concluzie

### Rezumat Implementare:

**CLIENT:**
- 🎯 **Obiectiv:** Offline-first cu sincronizare automată
- 📦 **Componente noi:** 7 (ConnectivityManager, SyncQueue, SyncManager, etc.)
- ⏱️ **Timp:** 3-4 săptămâni
- 🔧 **Complexitate:** Medie-Mare

**ADMIN:**
- 🎯 **Obiectiv:** Dual mode (server + direct DB) cu auto-fallback
- 📦 **Componente noi:** 5 (DatabaseConnectionManager, Dual repositories, etc.)
- ⏱️ **Timp:** 3 săptămâni
- 🔧 **Complexitate:** Medie

**SERVER:**
- 🎯 **Obiectiv:** Sync API + tombstones + timestamps
- 📦 **Componente noi:** 3 endpoints + migrations
- ⏱️ **Timp:** 2 săptămâni
- 🔧 **Complexitate:** Mică-Medie

### Ordine Recomandată Implementare:

1. **SERVER Sync API** (Faza 2) - Foundation pentru tot
2. **CLIENT Offline-First** (Faza 1) - Impact maxim pentru utilizatori
3. **ADMIN Dual Mode** (Faza 3) - Nice to have, nu critic
4. **ADMIN Cache** (Faza 4) - Optimization
5. **Security Hardening** (Faza 5) - Pre-production

### Beneficii Finale:

✅ **CLIENT:** App funcționează perfect offline, UX excelent
✅ **ADMIN:** Redundanță - funcționează chiar dacă serverul pică
✅ **SISTEM:** Arhitectură robustă, scalabilă, production-ready

---

**Document creat:** 2026-01-19
**Versiune:** 1.0
**Autor:** Claude Code Analysis
**Status:** ✅ Ready for Implementation