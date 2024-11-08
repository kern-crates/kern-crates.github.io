<template>
  <div>
    <DataTable :value="data" tableStyle="min-width: 50rem; margin: 0 5px 0 0;" scrollable :scrollHeight="tableHeight"
      showGridlines selectionMode="single" v-model:selection="selectedPkg" v-model:filters="selected.text"
      :globalFilterFields="['user', 'repo', 'pkg', 'description', 'categories']" removableSort sortMode="multiple"
      paginator :rows="10" :rowsPerPageOptions="[5, 10, 20, 50, 100, 200, 1000]">

      <template #header>
        <div style="display: flex; justify-content: space-between;">
          <div style="display: flex; gap: 20px;">
            <MultiSelect v-model="selected.categories" display="chip" :options="categories" filter
              :maxSelectedLabels="4" placeholder="Select Categories" />

            <MultiSelect v-model="selected.keywords" display="chip" :options="keywords" filter :maxSelectedLabels="4"
              placeholder="Select Keywords" />

            <MultiSelect v-model="selected.authors" display="chip" :options="authors" filter :maxSelectedLabels="4"
              placeholder="Select Authors" />

            <MultiSelect v-model="selected.kinds" display="chip" :options="kinds" filter :maxSelectedLabels="4"
              placeholder="Select Crate Kinds" />
          </div>

          <div>
            <IconField>
              <InputIcon>
                <i class="pi pi-search" />
              </InputIcon>
              <InputText style="width: 100%" v-model="selected.text['global'].value"
                placeholder="Search in all text columns" />
            </IconField>
          </div>

        </div>
      </template>

      <Column frozen sortable field="idx" header="Idx" />
      <Column frozen sortable field="user" header="User" style="min-width: 150px;" />

      <Column frozen sortable field="repo" header="Repo" style="min-width: 180px;">
        <template #body="{ data }">
          <NuxtLink :to="`https://github.com/${data.user}/${data.repo}`" target="_blank" class="nav-link">
            {{ data.repo }}
          </NuxtLink>
        </template>
      </Column>

      <Column frozen sortable field="pkg" header="Package" style="min-width: 200px;" />

      <Column sortable field="version" header="Version" style="text-align: center;" />
      <Column sortable field="lib" header="Lib" style="text-align: center;" />
      <Column sortable field="bin" header="Bin" style="text-align: center;" />
      <Column sortable field="dependencies" header="Depen-dencies" style="text-align: center;" />

      <Column sortable field="testcases" header="Test Cases" style="text-align: center; font-weight: bold">
        <template #body="{ data }">
          <span :style="{ color: data.testcases_color }">
            {{ data.testcases }}
          </span>
        </template>
      </Column>

      <Column sortable field="tests" header="Tests" style="text-align: center;" />
      <Column sortable field="examples" header="Examples" style="text-align: center;" />
      <Column sortable field="benches" header="Benches" style="text-align: center;" />

      <Column field="documentation" header="Doc" style="text-align: center;">
        <template #body="{ data }">
          <NuxtLink v-if="data.documentation" :to="data.documentation" target="_blank" class="nav-link">
            <Button icon="pi pi-external-link" link />
          </NuxtLink>
        </template>
      </Column>

      <Column field="latest_doc" header="Latest Doc" style="text-align: center;">
        <template #body="{ data }">
          <NuxtLink v-if="data.latest_doc" :to="data.latest_doc" target="_blank" class="nav-link">
            <Button icon="pi pi-external-link" link />
          </NuxtLink>
        </template>
      </Column>

      <Column field="homepage" header="Home Page" style="text-align: center;">
        <template #body="{ data }">
          <NuxtLink v-if="data.homepage" :to="data.homepage" target="_blank" class="nav-link">
            <Button icon="pi pi-external-link" link />
          </NuxtLink>
        </template>
      </Column>

      <Column sortable field="categories" header="Categories" style="min-width: 200px;">
        <template #body="{ data: { categories } }">
          <div v-for="tag of categories">
            <Tag severity="warn" :value="tag" style="margin-bottom: 5px;"></Tag>
          </div>
        </template>
      </Column>

      <Column sortable field="keywords" header="KeyWords" style="min-width: 150px;">
        <template #body="{ data: { keywords } }">
          <div v-for="tag of keywords">
            <Tag severity="warn" :value="tag" style="margin-bottom: 5px;"></Tag>
          </div>
        </template>
      </Column>

      <Column field="description" header="Description" style="min-width: 280px;" />

      <Column sortable field="author" header="Author" style="min-width: 300px;">
        <template #body="{ data: { author } }">
          <div v-for="tag of author">
            <Tag severity="info" :value="tag" style="margin-bottom: 5px;"></Tag>
          </div>
        </template>
      </Column>

    </DataTable>

    <Dialog v-model:visible="dialogShow" modal :style="{ width: '70%' }">
      <template #header>
        <span style="display: inline-flex; justify-content: center; gap: 40px; font-size: larger; font-weight: bold;">
          <div>
            <NuxtLink :to="dialogHeader?.repo_url" target="_blank">
              <Tag icon="pi pi-github" severity="info" style="font-weight: bold;">
                {{ dialogHeader?.repo }}
              </Tag>
            </NuxtLink>
          </div>

          <div>Test Cases of package
            <span style="color: var(--p-emerald-500); margin-right: 5px;">{{ dialogHeader?.pkg_name }}</span>
          </div>
        </span>
      </template>

      <div>
        <div v-if="dialogHeader?.pkg.description" class="dialog-header">
          <b style="margin-right: 5px">Description:</b> <b style="color: var(--p-emerald-500)">{{
            dialogHeader?.pkg.description }}</b>
        </div>
        <div v-if="dialogHeader?.pkg.categories.length !== 0" class="dialog-header">
          <b style="margin-right: 5px">Categories:</b>
          <Tag v-for="tag of dialogHeader?.pkg.categories" severity="warn" :value="tag" style="margin-right: 6px;" />
        </div>
        <div v-if="dialogHeader?.pkg.keywords.length !== 0" class="dialog-header">
          <b style="margin-right: 5px">KeyWords:</b>
          <Tag v-for="tag of dialogHeader?.pkg.keywords" severity="warn" :value="tag" style="margin-right: 6px;" />
        </div>
        <div v-if="dialogHeader?.pkg.authors.length !== 0" class="dialog-header">
          <b style="margin-right: 5px">Authors:</b>
          <Tag v-for="tag of dialogHeader?.pkg.authors" severity="info" :value="tag" style="margin-right: 6px;"></Tag>
        </div>
        <div v-if="dialogHeader?.testcase_count !== 0" class="dialog-header">
          <b style="margin-right: 5px">Test Cases:</b>
          Duration: {{ dialogHeader?.testcase_ms }}ms,
          Total: {{ dialogHeader?.testcase_count }},

          <span v-if="dialogHeader?.testcase_failed === 0" :style="{ color: color.green, 'font-weight': 'bold' }">
            All passed!
          </span>
          <span v-else :style="{ color: color.red, 'font-weight': 'bold' }">
            Failed
            ({{ Math.round(100 * (dialogHeader?.testcase_failed ?? 0) / (dialogHeader?.testcase_count ?? 0)) }}%)
            : {{ dialogHeader?.testcase_failed }}
          </span>
        </div>

        <InfoTestCases :tests="testCases" />
      </div>
    </Dialog>
  </div>
</template>

<script setup lang="ts">
import type { Pkg, PkgInfo, Test } from '~/shared/info';
import { unique_field, unique_field_bool } from '~/shared/info';
import { FilterMatchMode } from '@primevue/core/api';

const { color } = storeToRefs(useColorStore());

const summaries = ref<PkgInfo[]>([]);

githubFetch<PkgInfo[]>({
  path: "plugin/cargo/info/summaries.json"
}).then(val => {
  summaries.value = val;
});

// 需要构建期间设置了 DOCS_URL 环境变量，它指向 rustdoc 仓库的部署地址，来构造 docs.json 地址。
function defaultDocs(): string {
  const runtimeConfig = useRuntimeConfig();
  const url = runtimeConfig.public.docs_url || "https://os-checker.github.io/docs";
  return url.replace(/\/$/, "") + "/docs.json";
}
const docs_json_url = defaultDocs();
const docs = ref();
$fetch(docs_json_url).then(val => docs.value = val);

const summaryTable = computed<SummaryTable[]>(() => {
  const value = summaries.value.map(val => {
    return Object.entries(val.pkgs).map(([name, pkg]) => {
      let testcases_color = null;
      if (pkg.testcases?.pkg_tests_count) {
        if (pkg.testcases?.failed === 0) {
          testcases_color = color.value.green;
        } else {
          testcases_color = color.value.red;
        }
      }
      return {
        idx: 0,
        user: val.user,
        repo: val.repo,
        pkg: name,
        version: pkg.version,
        lib: pkg.lib ? "✅" : null,
        bin: pkg.bin ? "✅" : null,
        dependencies: pkg.dependencies || null,
        testcases: pkg.testcases?.pkg_tests_count ?? null,
        testcases_color,
        tests: pkg.tests || null,
        examples: pkg.examples || null,
        benches: pkg.benches || null,
        author: pkg.authors.length === 0 ? null : pkg.authors,
        description: pkg.description,
        keywords: pkg.keywords.length === 0 ? null : pkg.keywords,
        categories: pkg.categories.length === 0 ? null : pkg.categories,
        // os_categories: pkg.os_categories.length === 0 ? null : pkg.os_categories,
        documentation: pkg.documentation,
        readme: pkg.readme,
        homepage: pkg.homepage,
        latest_doc: docs.value[val.user]?.[val.repo]?.[name] ?? null
      }
    })
  }).flat();

  return value.sort((a, b) => {
    const a_test = a.testcases ?? 0;
    const b_test = b.testcases ?? 0;
    if (a_test < b_test) {
      return 1;
    } else if (a_test > b_test) {
      return -1;
    } else if (a.user < b.user) {
      return -1;
    } else if (a.user > b.user) {
      return 1;
    } else if (a.repo < b.repo) {
      return -1;
    } else if (a.repo > b.repo) {
      return 1;
    } else if (a.pkg < b.pkg) {
      return -1;
    } else if (a.pkg > b.pkg) {
      return 1;
    }
    return 0;
  }).map((val, idx) => {
    val.idx = idx + 1;
    return val;
  });
});

type SummaryTable = {
  idx: number; user: string; repo: string; pkg: string; version: string;
  lib: string | null; bin: string | null; dependencies: number | null; testcases: number | null; testcases_color: string | null;
  tests: number | null; examples: number | null; benches: number | null; keywords: string[] | null;
  author: string[] | null; description: string; categories: string[] | null;
  documentation: string | null; readme: string | null; homepage: string | null; latest_doc: string | null;
};
const data = ref<SummaryTable[]>([]);
watch(summaryTable, (val) => data.value = val);

const categories = computed(() => unique_field(summaries.value, pkg => pkg.categories));
const keywords = computed(() => unique_field(summaries.value, pkg => pkg.keywords));
const authors = computed(() => unique_field(summaries.value, pkg => pkg.authors));
const kinds = computed(() => {
  const val = summaries.value;
  const is_lib = unique_field_bool(val, pkg => pkg.lib);
  const is_bin = unique_field_bool(val, pkg => pkg.bin);
  const is_testcases = unique_field_bool(val, pkg => pkg.testcases?.pkg_tests_count ? true : false);
  const is_tests = unique_field_bool(val, pkg => pkg.tests > 0);
  const is_examples = unique_field_bool(val, pkg => pkg.examples > 0);
  const is_benches = unique_field_bool(val, pkg => pkg.benches > 0);

  let arr = [];
  if (is_lib) { arr.push("Lib"); }
  if (is_bin) { arr.push("Bin"); }
  if (is_testcases) { arr.push("TestCases"); }
  if (is_tests) { arr.push("Tests"); }
  if (is_examples) { arr.push("Examples"); }
  if (is_benches) { arr.push("Benches"); }
  return arr;
});

const selected = reactive<{
  categories: string[],
  keywords: string[],
  authors: string[],
  kinds: string[],
  text: any
}>({
  categories: [], keywords: [], authors: [], kinds: [],
  // interactive filter/search inputs
  text: { global: { value: null, matchMode: FilterMatchMode.CONTAINS }, }
});
watchEffect(() => {
  const cat = selected.categories;
  const keywords = selected.keywords;
  const au = selected.authors;
  const ks = selected.kinds;

  const is_empty_cat = cat.length === 0;
  const is_empty_keywords = keywords.length === 0;
  const is_empty_au = au.length === 0;
  const is_empty_k = ks.length === 0;

  // reset
  if (is_empty_cat && is_empty_keywords && is_empty_au && is_empty_k) {
    data.value = summaryTable.value;
    return;
  }

  data.value = summaryTable.value.filter(val => {
    const find_cat = cat.find(c => val.categories?.find(vc => vc === c));
    const find_keywords = keywords.find(k => val.keywords?.find(kw => kw === k));
    const find_au = au.find(a => val.author?.find(va => va === a));
    let find_k = true;
    for (const k of ks) {
      switch (k) {
        case "Lib": { find_k &&= val.lib === '✅'; continue; };
        case "Bin": { find_k &&= val.bin === '✅'; continue; };
        case "TestCases": { find_k &&= val.testcases ? true : false; continue; };
        case "Tests": { find_k &&= val.tests ? true : false; continue; };
        case "Examples": { find_k &&= val.examples ? true : false; continue; };
        case "Benches": { find_k &&= val.benches ? true : false; continue; };
        default: ;
      }
    }

    return (is_empty_cat ? true : find_cat)
      && (is_empty_keywords ? true : find_keywords)
      && (is_empty_au ? true : find_au) && (is_empty_k ? true : find_k);
  }).map((x, idx) => {
    x.idx = idx + 1;
    return x;
  });
});

const dialogShow = ref(false);
const dialogHeader = ref<{
  repo: string, repo_url: string, pkg_name: string, pkg: Pkg,
  testcase_count: number, testcase_failed: number, testcase_ms: number
} | null>();
const testCases = ref<Test[]>([]);

type SelectedRow = { user: string, repo: string, pkg: string };
const selectedPkg = ref<SelectedRow | null>(null);
watch(selectedPkg, val => {
  // for now, pop up a dialog to display testcases only if any 
  dialogShow.value = true;

  if (!val) { return; }

  const pkg = summaries.value
    .find(summary => summary.user === val.user && summary.repo === val.repo)
    ?.pkgs[val.pkg];

  if (!pkg) { return; }

  const repo = `${val.user}/${val.repo}`;
  const repo_url = `https://github.com/${repo}`;

  dialogHeader.value = {
    repo, repo_url, pkg_name: val.pkg, pkg,
    testcase_count: pkg.testcases?.pkg_tests_count ?? 0,
    testcase_failed: pkg.testcases?.failed ?? 0,
    testcase_ms: pkg.testcases?.duration_ms ?? 0,
  };

  testCases.value = pkg.testcases?.tests ?? [];
});


const tableHeight = ref("800px");
onMounted(() => {
  const viewportHeight = window.innerHeight;
  tableHeight.value = `${viewportHeight * 0.8}px`;
  window.addEventListener('resize', () => {
    const viewportHeight = window.innerHeight;
    tableHeight.value = `${viewportHeight * 0.8}px`;
  });
});

const route = useRoute();
function updateFilter(query: {
  categories?: string,
  keywords?: string,
  authors?: string,
  kinds?: string,
  text?: string,
}) {
  if (query.categories) { selected.categories = decodeURIComponent(query.categories).split(","); }
  if (query.keywords) { selected.keywords = decodeURIComponent(query.keywords).split(","); }
  if (query.authors) { selected.authors = decodeURIComponent(query.authors).split(","); }

  if (query.kinds) {
    const filter = new Set([
      "Lib", "Bin", "TestCases", "Tests", "Examples", "Benches"
    ]);
    selected.kinds = decodeURIComponent(query.kinds).split(",").filter(k => filter.has(k));
  }

  if (query.text) {
    selected.text.global.value = decodeURIComponent(query.text);
  }
}
updateFilter(route.query);
// watch(() => route.query, updateFilter);

const router = useRouter();
watch(selected, (sel) => {
  let query: any = {};
  if (sel.categories.length !== 0) {
    query.categories = encodeURIComponent(sel.categories.join(","));
  }
  if (sel.keywords.length !== 0) {
    query.keywords = encodeURIComponent(sel.keywords.join(","));
  }
  if (sel.authors.length !== 0) {
    // FIXME: what if author string contains `,`
    query.authors = encodeURIComponent(sel.authors.join(","));
  }
  if (sel.kinds.length !== 0) {
    query.kinds = encodeURIComponent(sel.kinds.join(","));
  }
  if (sel.text.global.value) {
    query.text = encodeURIComponent(sel.text.global.value);
  }

  router.push({ path: route.path, query });
});
// clear query when the page is loaded
// if (Object.keys(route.query).length !== 0) {
//   router.push({ path: route.path });
// }

useHead({ title: 'Package Information' });
</script>

<style lang="css">
.dialog-header {
  margin-bottom: 10px;
}
</style>
