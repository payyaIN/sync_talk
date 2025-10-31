
import { Router } from 'express';
import swaggerUi from 'swagger-ui-express';
import swaggerJSDoc from 'swagger-jsdoc';
const options = { definition: { openapi: '3.0.0', info: { title: 'SyncTalk API', version: '1.2.1' } }, apis: ['./src/modules/**/*.ts'] };
const swaggerSpec = swaggerJSDoc(options as any);
export const docsRouter = Router().use('/', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
