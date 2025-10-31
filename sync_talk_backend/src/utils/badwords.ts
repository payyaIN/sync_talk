export const bannedWords = ["fuck", "shit", "bitch", "asshole", "bastard"];
export const containsBadWords = (text: string) =>
  bannedWords.some((word) => text.toLowerCase().includes(word));
