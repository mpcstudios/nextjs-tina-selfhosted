import { createMediaHandler } from "next-tinacms-s3/dist/handlers";
import type { NextApiRequest, NextApiResponse } from "next";

export const config = {
  api: {
    bodyParser: false,
  },
};

const mediaRoot = process.env.S3_MEDIA_ROOT || "";

const s3Handler = createMediaHandler({
  config: {
    credentials: {
      accessKeyId: process.env.S3_ACCESS_KEY || "",
      secretAccessKey: process.env.S3_SECRET_KEY || "",
    },
    region: process.env.S3_REGION || "us-east-1",
  },
  bucket: process.env.S3_BUCKET || "mpcstudios-media",
  mediaRoot,
  authorized: async () => {
    return true;
  },
});

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Prepend mediaRoot to the upload key so files go into the site's folder
  if (req.method === "GET" && req.query.key) {
    const key = Array.isArray(req.query.key)
      ? req.query.key[0]
      : req.query.key;
    const prefix = mediaRoot.replace(/^\/|\/$/g, "");
    if (prefix && !key.startsWith(prefix + "/")) {
      req.query.key = `${prefix}/${key}`;
    }
  }

  return s3Handler(req, res);
}
