import { createMediaHandler } from "next-tinacms-s3/dist/handlers";

export const config = {
  api: {
    bodyParser: false,
  },
};

export default createMediaHandler({
  config: {
    credentials: {
      accessKeyId: process.env.S3_ACCESS_KEY || "",
      secretAccessKey: process.env.S3_SECRET_KEY || "",
    },
    region: process.env.S3_REGION || "us-east-1",
  },
  bucket: process.env.S3_BUCKET || "mpcstudios-media",
  mediaRoot: process.env.S3_MEDIA_ROOT || "",
  authorized: async () => {
    return true;
  },
});
