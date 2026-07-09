"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.containsBadWords = exports.bannedWords = void 0;
exports.bannedWords = ["fuck", "shit", "bitch", "asshole", "bastard"];
const containsBadWords = (text) => exports.bannedWords.some((word) => text.toLowerCase().includes(word));
exports.containsBadWords = containsBadWords;
