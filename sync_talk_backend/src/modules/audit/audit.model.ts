
import mongoose, { Schema, Document } from 'mongoose';
export interface IAudit extends Document {
  actor: string; action: string; target?: string; meta?: any; createdAt: Date;
}
const AuditSchema = new Schema<IAudit>({
  actor: { type: String, required: true },
  action: { type: String, required: true },
  target: { type: String },
  meta: { type: Object }
}, { timestamps: { createdAt: true, updatedAt: false } });
export const Audit = mongoose.model<IAudit>('Audit', AuditSchema);
