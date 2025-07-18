/**
 * Junction table linking issues to their labels
 * Database table: issue_label_relations
 * Primary key: (issueId, labelId)
 */
export interface IssueLabelRelation {
  /** Foreign key to issues.id */
  issueId: string;
  /** Foreign key to issue_labels.id */
  labelId: string;
  /** Timestamp when the label was added to the issue */
  createdAt: Date;
}