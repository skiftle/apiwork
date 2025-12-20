import {
  features as rawFeatures,
  whyPoints,
  moreFeatures,
  type Feature,
} from "./homepage";

export interface HighlightedFeature extends Feature {
  highlightedBlocks: string[];
}

export interface HomepageData {
  features: HighlightedFeature[];
  whyPoints: typeof whyPoints;
  moreFeatures: typeof moreFeatures;
}

declare const data: HomepageData;
export { data };

export default {
  async load(): Promise<HomepageData> {
    const { createHighlighter, createCssVariablesTheme } = await import(
      "shiki"
    );

    const theme = createCssVariablesTheme({
      name: "css-variables",
      variablePrefix: "--shiki-",
    });

    const highlighter = await createHighlighter({
      themes: [theme],
      langs: ["ruby", "typescript", "json"],
    });

    const features = rawFeatures.map((feature) => ({
      ...feature,
      highlightedBlocks: feature.codeBlocks.map((block) =>
        highlighter.codeToHtml(block.code, {
          lang: block.language,
          theme: "css-variables",
        })
      ),
    }));

    return { features, whyPoints, moreFeatures };
  },
};
