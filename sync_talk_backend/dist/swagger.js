"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.docsRouter = void 0;
const express_1 = require("express");
const swagger_ui_express_1 = __importDefault(require("swagger-ui-express"));
const swagger_jsdoc_1 = __importDefault(require("swagger-jsdoc"));
const options = { definition: { openapi: '3.0.0', info: { title: 'SyncTalk API', version: '1.2.1' } }, apis: ['./src/modules/**/*.ts'] };
const swaggerSpec = (0, swagger_jsdoc_1.default)(options);
exports.docsRouter = (0, express_1.Router)().use('/', swagger_ui_express_1.default.serve, swagger_ui_express_1.default.setup(swaggerSpec));
