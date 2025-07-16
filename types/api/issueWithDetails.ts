import { Issue } from "../entities/issue";
import { User } from "../entities/user";
import { IssueLabel } from "../entities/issueLabel";
import { Comment } from "../entities/comment";
import { Link } from "../entities/link";

// ===== API RESPONSE TYPE (Composed from DB models) =====
// This type represents a complete issue with all its relationships loaded
// Used for detailed issue views where all related data is needed

export interface IssueWithDetails {
  issue: Issue;
  creator: User;
  assignee?: User;
  labels: IssueLabel[];
  comments: Comment[];
  subscribers: User[];
  links: Link[];
  parentIssue?: Issue;
  subIssues?: Issue[];
  relatedIssues?: Issue[];
}
