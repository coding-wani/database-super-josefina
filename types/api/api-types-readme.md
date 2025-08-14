# API Types Documentation

Ces types TypeScript définissent la structure des réponses API pour optimiser les performances et simplifier le développement frontend.

## Vue d'ensemble

Les types dans ce dossier `/types/api` représentent des **réponses API composées** qui combinent plusieurs entités de base via des JOINs SQL. Ils ne représentent PAS des tables de base de données, mais plutôt des structures de données optimisées pour l'utilisation frontend.

## Types disponibles

### Vue d'ensemble des 8 types API

1. **`CommentWithReactions`** - Comments avec réactions groupées
2. **`IssueWithDetails`** - Issues avec toutes les relations chargées
3. **`ProjectOverview`** - Vue d'ensemble complète d'un projet
4. **`TeamMembershipWithDetails`** - Adhésion équipe avec détails
5. **`UserDashboardResponse`** - Dashboard utilisateur complet
6. **`UserWithRoles`** - Utilisateur avec informations de rôles
7. **`WorkspaceAnalytics`** - Analyses et métriques du workspace
8. **`WorkspaceMembershipWithDetails`** - Adhésion workspace avec détails

---

### 1. `CommentWithReactions`

**Objectif** : Fournir les commentaires avec leurs réactions agrégées pour éviter les requêtes N+1.

#### Cas d'usage
- Affichage des commentaires sur les issues
- Threads de discussion avec réactions
- Éviter les appels API séparés pour chaque réaction

#### Structure
```typescript
interface CommentWithReactions {
  // Hérite de Comment (contenu, auteur, dates...)
  reactions: ReactionSummary[]; // Réactions groupées par type
}

interface ReactionSummary {
  reaction: Reaction;      // Type de réaction (emoji)
  users: User[];           // Utilisateurs qui ont réagi
  count: number;           // Nombre total
}
```

#### Exemple d'utilisation
```typescript
function CommentItem({ comment }: { comment: CommentWithReactions }) {
  return (
    <div className="comment">
      <p>{comment.content}</p>
      
      {/* Affichage des réactions */}
      <div className="reactions">
        {comment.reactions.map(({ reaction, users, count }) => (
          <button key={reaction.id} className="reaction-btn">
            {reaction.emoji} {count}
            <Tooltip>
              {users.map(u => u.username).join(', ')}
            </Tooltip>
          </button>
        ))}
      </div>
    </div>
  );
}
```

---

### 2. `IssueWithDetails`

**Objectif** : Charger toutes les données nécessaires pour l'affichage détaillé d'une issue.

#### Cas d'usage
- Page de détail d'une issue (`/issue/[id]`)
- Modal d'édition d'issue
- Sidebar d'issue avec toutes les informations

#### Structure
```typescript
interface IssueWithDetails {
  issue: Issue;                // Issue principale
  creator: User;               // Créateur
  assignee?: User;             // Assigné
  labels: IssueLabel[];        // Étiquettes
  comments: Comment[];         // Commentaires
  subscribers: User[];         // Abonnés
  links: Link[];               // Liens/attachements
  parentIssue?: Issue;         // Issue parente
  subIssues?: Issue[];         // Sous-issues
  relatedIssues?: Issue[];     // Issues liées
}
```

#### Exemple d'utilisation
```typescript
function IssueDetailPage({ issueId }: { issueId: string }) {
  const details = await fetchIssueWithDetails(issueId);
  
  return (
    <div className="issue-detail">
      <IssueHeader 
        issue={details.issue}
        creator={details.creator}
        assignee={details.assignee}
      />
      
      <IssueTags labels={details.labels} />
      
      <IssueDescription content={details.issue.description} />
      
      <IssueComments comments={details.comments} />
      
      <IssueSidebar 
        subscribers={details.subscribers}
        links={details.links}
        parentIssue={details.parentIssue}
        subIssues={details.subIssues}
        relatedIssues={details.relatedIssues}
      />
    </div>
  );
}
```

---

### 3. `ProjectOverview`

**Objectif** : Dashboard complet d'un projet avec métriques et activité récente.

#### Cas d'usage
- Dashboard de projet (`/project/[id]`)
- Vue d'ensemble pour les chefs de projet
- Métriques de performance et suivi

#### Structure
```typescript
interface ProjectOverview {
  project: Project;            // Projet principal
  lead?: User;                 // Chef de projet
  team?: Team;                 // Équipe assignée
  milestones: Milestone[];     // Jalons
  members: Array<{
    user: User;
    role: string;
  }>;
  issueStats: {
    total: number;
    byStatus: Record<Status, number>;
    byPriority: Record<Priority, number>;
    overdue: number;
    completionRate: number;
  };
  recentActivity: ActivityItem[];
}
```

#### Exemple d'utilisation
```typescript
function ProjectDashboard({ projectId }: { projectId: string }) {
  const overview = await fetchProjectOverview(projectId);
  
  return (
    <div className="project-dashboard">
      <ProjectHeader 
        project={overview.project}
        lead={overview.lead}
        team={overview.team}
      />
      
      <ProjectMetrics stats={overview.issueStats} />
      
      <MilestoneProgress milestones={overview.milestones} />
      
      <TeamMembers members={overview.members} />
      
      <ActivityFeed activities={overview.recentActivity} />
    </div>
  );
}
```

---

### 4. `UserWithRoles`

**Objectif** : Utilisateur avec informations complètes de rôles pour la gestion des permissions.

#### Cas d'usage
- Administration des utilisateurs
- Gestion des permissions
- Audit des accès et rôles

#### Structure
```typescript
interface UserWithRoles {
  user: User;                          // Données utilisateur
  roleAssignments: Array<{
    roleId: string;
    role: UserRole;                    // Détails du rôle avec permissions
    workspaceId?: string;              // Scope workspace si applicable
    assignedBy?: string;
    assignedByUser?: User;             // Qui a assigné
    assignedAt: Date;
    expiresAt?: Date;
  }>;
}
```

---

### 5. `WorkspaceAnalytics`

**Objectif** : Métriques complètes et analytics pour un workspace.

#### Cas d'usage
- Dashboard administrateur
- Rapports de performance
- Métriques d'équipe et utilisateur

#### Structure
```typescript
interface WorkspaceAnalytics {
  workspaceId: string;
  period: { start: Date; end: Date; };
  teamStats: TeamPerformanceMetrics[];
  userStats: UserActivityMetrics[];
  projectStats: ProjectProgressMetrics[];
  trends: {
    issueVelocity: number[];
    resolutionRate: number[];
    activeUsers: number[];
  };
  topLabels: LabelUsageMetrics[];
  summary: WorkspaceSummaryMetrics;
}
```

---

### 6. `UserDashboardResponse`

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

### 7. `TeamMembershipWithDetails`

**Objectif** : Fournir les informations complètes sur l'appartenance à une équipe.

#### Cas d'usage
- Page d'équipe (`/team/[id]`)
- Liste des membres d'une équipe
- Vérification des permissions (seul le lead peut gérer l'équipe)

#### Structure
```typescript
interface TeamMembershipWithDetails {
  membership: TeamMembership;  // Rôle et date d'adhésion
  team: Team;                  // Informations complètes de l'équipe
}
```

#### Exemple d'utilisation
```typescript
function TeamHeader({ teamData }: { teamData: TeamMembershipWithDetails }) {
  const { team, membership } = teamData;
  
  return (
    <div className="team-header">
      <h1>{team.icon} {team.name}</h1>
      {membership.role === 'admin' && (
        <button>Gérer l'équipe</button>
      )}
      <span>
        Vous êtes {membership.role} depuis {formatDate(membership.joinedAt)}
      </span>
    </div>
  );
}
```

---

### 8. `WorkspaceMembershipWithDetails`

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