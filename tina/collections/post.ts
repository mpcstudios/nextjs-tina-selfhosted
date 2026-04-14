import type { Collection } from "tinacms";

export const PostCollection: Collection = {
  name: "post",
  label: "Blog Posts",
  path: "content/posts",
  format: "md",
  fields: [
    {
      type: "string",
      name: "title",
      label: "Title",
      isTitle: true,
      required: true,
    },
    {
      type: "string",
      name: "excerpt",
      label: "Excerpt",
      ui: {
        component: "textarea",
      },
    },
    {
      type: "image",
      name: "featuredImage",
      label: "Featured Image",
    },
    {
      type: "string",
      name: "author",
      label: "Author",
    },
    {
      type: "datetime",
      name: "date",
      label: "Publish Date",
    },
    {
      type: "string",
      name: "status",
      label: "Status",
      options: ["draft", "published"],
    },
    {
      type: "rich-text",
      name: "body",
      label: "Body",
      isBody: true,
    },
  ],
  defaultItem: () => ({
    status: "draft",
    date: new Date().toISOString(),
  }),
};
