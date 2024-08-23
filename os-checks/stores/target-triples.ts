type TargetTriples = string[];

export const useTargetsStore = defineStore('targets', {
  state: () => ({
    targets: [] as TargetTriples,
  }),
  actions: {
    async fetch() {
      this.targets = await githubFetch({ repo: "database", path: "ui/target-triple.json" }) as TargetTriples;
    }
  }
})