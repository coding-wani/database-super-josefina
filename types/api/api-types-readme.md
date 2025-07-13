# API Types Documentation

Ces types TypeScript définissent la structure des réponses API pour optimiser les performances et simplifier le développement frontend.

## Vue d'ensemble

Les types dans ce dossier `/types/api` représentent des **réponses API composées** qui combinent plusieurs entités de base via des JOINs SQL. Ils ne représentent PAS des tables de base de données, mais plutôt des structures de données optimisées pour l'utilisation frontend.

## Types disponibles

### 1. `UserDashboardResponse`

**Objectif** : Fournir toutes les données nécessaires au chargement initial de l'application en un seul appel API.

#### Cas d'usage
- Page de connexion / chargement initial
- Rechargement des données utilisateur après changement de workspace
- Affichage du workspace switcher dans la sidebar

#### Structure
```typescript
interface UserDashboardResponse {
  user: User;
  workspaces: Array<{
    membership: WorkspaceMembership;
    workspace: Workspace;
  }>;
  teams: Array<{
    membership: TeamMembership;
    team: Team;
  }>;
}
```

#### Exemple d'utilisation

**❌ SANS ce type (mauvaise approche) :**
```typescript
// 4+ appels API nécessaires
const user = await fetchUser(userId);
const memberships = await fetchUserWorkspaceMemberships(userId);
const workspaces = await fetchWorkspaces(memberships.map(m => m.workspaceId));
const teams = await fetchUserTeams(userId);
```

**✅ AVEC ce type (bonne approche) :**
```typescript
// 1 seul appel API
const dashboard = await fetchUserDashboard(userId);
// dashboard contient TOUT : user + workspaces + teams
```

#### Utilisation dans les composants
```typescript
// Sidebar component
function Sidebar({ dashboard }: { dashboard: UserDashboardResponse }) {
  return (
    <div>
      {/* Workspace Switcher */}
      <WorkspaceSwitcher 
        current={dashboard.user.currentWorkspaceId}
        workspaces={dashboard.workspaces}
      />
      
      {/* Liste des teams */}
      {dashboard.teams.map(({ team, membership }) => (
        <TeamItem 
          key={team.id}
          name={team.name}
          icon={team.icon}
          role={membership.role} // Accès au rôle de l'utilisateur
        />
      ))}
    </div>
  );
}
```

### 2. `WorkspaceMembershipWithDetails`

**Objectif** : Afficher les détails complets d'une adhésion à un workspace, incluant les informations sur qui a invité le membre.

#### Cas d'usage
- Page de gestion des membres du workspace (`/workspace/[id]/members`)
- Affichage de l'historique des invitations
- Audit trail des accès

#### Structure
```typescript
interface WorkspaceMembershipWithDetails {
  membership: WorkspaceMembership;
  workspace: Workspace;
  invitedByUser?: User; // Détails complets de qui a invité
}
```

#### Exemple d'utilisation
```typescript
// Page : /workspace/IW/members
function WorkspaceMembers() {
  const members = await fetchWorkspaceMembers(workspaceId);
  
  return (
    <table>
      <thead>
        <tr>
          <th>Membre</th>
          <th>Rôle</th>
          <th>Rejoint le</th>
          <th>Invité par</th>
        </tr>
      </thead>
      <tbody>
        {members.map(({ membership, workspace, invitedByUser }) => (
          <tr key={membership.id}>
            <td>{/* Infos du membre */}</td>
            <td>{membership.role}</td>
            <td>{formatDate(membership.joinedAt)}</td>
            <td>
              {invitedByUser && (
                <>
                  <img src={invitedByUser.avatar} />
                  {invitedByUser.username}
                </>
              )}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
```

### 3. `TeamMembershipWithDetails`

**Objectif** : Fournir les informations complètes sur l'appartenance à une équipe.

#### Cas d'usage
- Page d'équipe (`/team/[id]`)
- Liste des membres d'une équipe
- Vérification des permissions (seul le lead peut gérer l'équipe)

#### Structure
```typescript
interface TeamMembershipWithDetails {
  membership: TeamMembership;
  team: Team;
}
```

#### Exemple d'utilisation
```typescript
// Composant : TeamHeader
function TeamHeader({ teamData }: { teamData: TeamMembershipWithDetails }) {
  const { team, membership } = teamData;
  
  return (
    <div className="team-header">
      <h1>
        {team.icon} {team.name}
      </h1>
      {membership.role === 'lead' && (
        <button>Gérer l'équipe</button> // Seulement visible pour le lead
      )}
      <span>
        Vous êtes {membership.role} depuis {formatDate(membership.joinedAt)}
      </span>
    </div>
  );
}

// Liste des membres de l'équipe
function TeamMembersList({ teamId }: { teamId: string }) {
  const members = await fetchTeamMembers(teamId);
  
  return (
    <div>
      {members.map(({ membership, team }) => (
        <MemberCard
          key={membership.id}
          role={membership.role}
          joinedAt={membership.joinedAt}
          teamName={team.name}
        />
      ))}
    </div>
  );
}
```

## Avantages de cette approche

### 1. Performance
- **Sans types structurés** : 5-10 appels API pour construire une page
- **Avec types structurés** : 1 seul appel API optimisé avec JOINs SQL

### 2. Simplicité du code frontend
```typescript
// ❌ Sans types structurés
const [user, setUser] = useState();
const [workspaces, setWorkspaces] = useState();
const [teams, setTeams] = useState();
const [memberships, setMemberships] = useState();
// ... beaucoup de useEffect et de logique pour tout assembler

// ✅ Avec types structurés
const [dashboard, setDashboard] = useState<UserDashboardResponse>();
// Tout est déjà assemblé et typé !
```

### 3. Type Safety
TypeScript connaît exactement la structure de chaque réponse :
```typescript
// TypeScript vous guide
dashboard.workspaces[0].membership.role // ✅ Type-safe
dashboard.workspaces[0].workspace.name   // ✅ Type-safe
dashboard.workspaces[0].workspace.role   // ❌ Erreur ! 'role' n'existe pas sur workspace
```

### 4. Contrat Frontend/Backend
Ces types définissent un contrat clair entre le frontend et le backend :
```typescript
// Backend (Node.js/Express)
app.get('/api/user/:id/dashboard', async (req, res) => {
  const data: UserDashboardResponse = await getUserDashboard(req.params.id);
  res.json(data);
});

// Frontend sait exactement ce qu'il va recevoir
const { data }: { data: UserDashboardResponse } = await axios.get(
  `/api/user/${userId}/dashboard`
);
```

## Bonnes pratiques

1. **Ne pas dupliquer les données** : Ces types représentent des vues composées, pas des données stockées
2. **Utiliser pour les lectures uniquement** : Pour les écritures, utilisez les types de base (`User`, `Team`, etc.)
3. **Invalider le cache après modifications** : Quand vous modifiez des données, invalidez les caches des réponses composées
4. **Documenter les endpoints** : Chaque type devrait correspondre à un endpoint API documenté

## Exemple de requête SQL optimisée

Voici comment le backend peut construire efficacement une `UserDashboardResponse` :

```sql
WITH user_workspaces AS (
  SELECT 
    wm.*,
    row_to_json(w.*) as workspace
  FROM workspace_memberships wm
  JOIN workspaces w ON wm.workspace_id = w.id
  WHERE wm.user_id = $1
),
user_teams AS (
  SELECT 
    tm.*,
    row_to_json(t.*) as team
  FROM team_memberships tm
  JOIN teams t ON tm.team_id = t.id
  WHERE tm.user_id = $1
)
SELECT 
  row_to_json(u.*) as user,
  COALESCE(array_to_json(array_agg(DISTINCT uw.*)), '[]'::json) as workspaces,
  COALESCE(array_to_json(array_agg(DISTINCT ut.*)), '[]'::json) as teams
FROM users u
LEFT JOIN user_workspaces uw ON true
LEFT JOIN user_teams ut ON true
WHERE u.id = $1
GROUP BY u.id;
```

Cette requête récupère toutes les données nécessaires en une seule exécution, ce qui est beaucoup plus efficace que plusieurs requêtes séparées.