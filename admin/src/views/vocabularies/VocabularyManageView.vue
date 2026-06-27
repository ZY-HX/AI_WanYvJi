<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import dayjs from 'dayjs'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { Upload } from '@element-plus/icons-vue'
import {
  createVocabulary,
  deleteVocabulary,
  getPublicVocabularies,
  updateVocabulary,
  type Vocabulary,
  type CreateVocabularyPayload,
  type UpdateVocabularyPayload
} from '../../api/vocabularies'
import {
  getAdminWords,
  createAdminWord,
  updateAdminWord,
  deleteAdminWord,
  importWordsFromFile,
  type Word,
  type WordCreatePayload,
  type WordUpdatePayload,
  type WordImportResult
} from '../../api/words'

const loading = ref(false)
const items = ref<Vocabulary[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const dialogVisible = ref(false)
const dialogTitle = ref('')
const isEdit = ref(false)
const editingId = ref<number | null>(null)
const submitting = ref(false)

const formRef = ref<FormInstance>()
const form = reactive<CreateVocabularyPayload & UpdateVocabularyPayload>({
  name: '',
  description: '',
  category: '',
  language: 'EN'
})

const rules: FormRules = {
  name: [
    { required: true, message: '请输入词库名称', trigger: 'blur' },
    { max: 100, message: '词库名称不能超过100个字符', trigger: 'blur' }
  ],
  category: [
    { required: true, message: '请选择词库分类', trigger: 'change' },
    { max: 50, message: '词库分类不能超过50个字符', trigger: 'change' }
  ],
  description: [
    { max: 500, message: '词库描述不能超过500个字符', trigger: 'blur' }
  ],
  language: [
    { required: true, message: '请选择学习语种', trigger: 'change' }
  ]
}

const categoryOptions = ['四级', '六级', '考研', '托福', '雅思', 'GRE', '商务英语', '日常用语', '德语入门', '法语入门', '西班牙语入门', '其他']

const languageOptions = [
  { label: '英语', value: 'EN' },
  { label: '日语', value: 'JA' },
  { label: '韩语', value: 'KO' },
  { label: '德语', value: 'DE' },
  { label: '法语', value: 'FR' },
  { label: '西班牙语', value: 'ES' }
]

const query = reactive({
  current: 1,
  size: 10,
})

const wordDialogVisible = ref(false)
const currentWordBankId = ref<number | null>(null)
const currentWordBankName = ref('')
const wordLoading = ref(false)
const words = ref<Word[]>([])
const wordCurrentPage = ref(1)
const wordPageSize = ref(10)
const wordTotal = ref(0)

const wordFormDialogVisible = ref(false)
const wordFormTitle = ref('')
const isWordEdit = ref(false)
const editingWordId = ref<number | null>(null)
const wordSubmitting = ref(false)

const wordFormRef = ref<FormInstance>()
const wordForm = reactive<WordCreatePayload & WordUpdatePayload>({
  english: '',
  phonetic: '',
  chinese: '',
  example: ''
})

const wordRules: FormRules = {
  english: [
    { required: true, message: '请输入英文单词', trigger: 'blur' },
    { max: 100, message: '英文单词不能超过100个字符', trigger: 'blur' }
  ],
  chinese: [
    { required: true, message: '请输入中文释义', trigger: 'blur' },
    { max: 500, message: '中文释义不能超过500个字符', trigger: 'blur' }
  ],
  phonetic: [
    { max: 100, message: '音标不能超过100个字符', trigger: 'blur' }
  ],
  example: [
    { max: 1000, message: '例句不能超过1000个字符', trigger: 'blur' }
  ]
}

const importDialogVisible = ref(false)
const importFile = ref<File | null>(null)
const importPreview = ref<string[]>([])
const importLoading = ref(false)
const importResult = ref<WordImportResult | null>(null)

onMounted(async () => {
  await fetchList(1)
})

async function fetchList(page = currentPage.value) {
  loading.value = true
  try {
    query.current = page
    query.size = pageSize.value
    const result = await getPublicVocabularies(query)

    const responseData = result

    currentPage.value = Number(responseData.current || page)
    pageSize.value = Number(responseData.size || pageSize.value)
    total.value = Number(responseData.total || 0)
    items.value = responseData.records ?? []
  } finally {
    loading.value = false
  }
}

function formatTime(value?: string) {
  if (!value) {
    return '-'
  }
  const parsed = dayjs(value)
  return parsed.isValid() ? parsed.format('YYYY-MM-DD HH:mm') : value
}

function resetForm() {
  form.name = ''
  form.description = ''
  form.category = ''
  editingId.value = null
  isEdit.value = false
}

function handleCreate() {
  resetForm()
  dialogTitle.value = '发布公共词库'
  isEdit.value = false
  dialogVisible.value = true
}

function handleEdit(item: Vocabulary) {
  resetForm()
  dialogTitle.value = '编辑词库信息'
  isEdit.value = true
  editingId.value = item.id
  form.name = item.name
  form.description = item.description || ''
  form.category = item.category || ''
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!formRef.value) return
  
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  if (!form.name.trim() || !form.category.trim()) {
    ElMessage.warning('词库名称和分类不能为空白字符')
    return
  }

  submitting.value = true
  try {
    if (isEdit.value && editingId.value) {
      const payload: UpdateVocabularyPayload = {
        name: form.name.trim(),
        description: form.description?.trim(),
        category: form.category.trim(),
        language: form.language
      }
      await updateVocabulary(editingId.value, payload)
      ElMessage.success('词库更新成功')
    } else {
      const payload: CreateVocabularyPayload = {
        name: form.name.trim(),
        description: form.description?.trim(),
        category: form.category.trim(),
        language: form.language
      }
      await createVocabulary(payload)
      ElMessage.success('词库发布成功')
    }
    dialogVisible.value = false
    await fetchList(currentPage.value)
  } finally {
    submitting.value = false
  }
}

async function handleDelete(item: Vocabulary) {
  const confirmed = await ElMessageBox.confirm(
    `确认删除公共词库「${item.name}」？此操作不可恢复。`,
    '删除确认',
    {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).catch(() => false)

  if (!confirmed) return

  try {
    await deleteVocabulary(item.id)
    ElMessage.success('词库已删除')
    await fetchList(currentPage.value)
  } catch (error) {
    console.error('删除失败:', error)
  }
}

async function handlePageChange(page: number) {
  await fetchList(page)
}

async function handleManageWords(item: Vocabulary) {
  currentWordBankId.value = item.id
  currentWordBankName.value = item.name
  wordDialogVisible.value = true
  await fetchWords(1)
}

async function fetchWords(page = wordCurrentPage.value) {
  if (!currentWordBankId.value) return

  wordLoading.value = true
  try {
    const result = await getAdminWords(currentWordBankId.value, { current: page, size: wordPageSize.value })

    /**
     * 🔧 兼容多种数据格式
     * - 标准格式：{ code, message, data: { current, size, total, records } }
     */
    const responseData = result?.data ?? result

    wordCurrentPage.value = Number(responseData.current || page)
    wordPageSize.value = Number(responseData.size || wordPageSize.value)
    wordTotal.value = Number(responseData.total || 0)
    words.value = responseData.records ?? []
  } finally {
    wordLoading.value = false
  }
}

function resetWordForm() {
  wordForm.english = ''
  wordForm.phonetic = ''
  wordForm.chinese = ''
  wordForm.example = ''
  editingWordId.value = null
  isWordEdit.value = false
}

function handleAddWord() {
  resetWordForm()
  wordFormTitle.value = '添加单词'
  isWordEdit.value = false
  wordFormDialogVisible.value = true
}

function handleEditWord(word: Word) {
  resetWordForm()
  wordFormTitle.value = '编辑单词'
  isWordEdit.value = true
  editingWordId.value = word.id
  wordForm.english = word.english
  wordForm.phonetic = word.phonetic || ''
  wordForm.chinese = word.chinese
  wordForm.example = word.example || ''
  wordFormDialogVisible.value = true
}

async function handleWordSubmit() {
  if (!wordFormRef.value) return

  const valid = await wordFormRef.value.validate().catch(() => false)
  if (!valid) return
  if (!wordForm.english.trim() || !wordForm.chinese.trim()) {
    ElMessage.warning('英文单词和中文释义不能为空白字符')
    return
  }

  wordSubmitting.value = true
  try {
    if (isWordEdit.value && editingWordId.value) {
      const payload: WordUpdatePayload = {
        english: wordForm.english.trim(),
        phonetic: wordForm.phonetic?.trim(),
        chinese: wordForm.chinese.trim(),
        example: wordForm.example?.trim()
      }
      await updateAdminWord(editingWordId.value, payload)
      ElMessage.success('单词更新成功')
    } else {
      const payload: WordCreatePayload = {
        english: wordForm.english.trim(),
        phonetic: wordForm.phonetic?.trim(),
        chinese: wordForm.chinese.trim(),
        example: wordForm.example?.trim()
      }
      await createAdminWord(currentWordBankId.value!, payload)
      ElMessage.success('单词添加成功')
    }
    wordFormDialogVisible.value = false
    await fetchWords(wordCurrentPage.value)
    await fetchList(currentPage.value)
  } finally {
    wordSubmitting.value = false
  }
}

async function handleDeleteWord(word: Word) {
  const confirmed = await ElMessageBox.confirm(
    `确认删除单词「${word.english}」？此操作不可恢复。`,
    '删除确认',
    {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).catch(() => false)

  if (!confirmed) return

  try {
    await deleteAdminWord(word.id)
    ElMessage.success('单词已删除')
    await fetchWords(wordCurrentPage.value)
    await fetchList(currentPage.value)
  } catch (error) {
    console.error('删除单词失败:', error)
  }
}

async function handleWordPageChange(page: number) {
  await fetchWords(page)
}

function handleImportWords() {
  importDialogVisible.value = true
  importFile.value = null
  importPreview.value = []
  importResult.value = null
}

function handleFileChange(uploadFile: any) {
  const file = uploadFile.raw
  if (!file) return

  if (!file.name.toLowerCase().endsWith('.txt')) {
    ElMessage.error('仅支持TXT文本文件')
    return
  }

  if (file.size > 5 * 1024 * 1024) {
    ElMessage.error('文件大小不能超过5MB')
    return
  }

  importFile.value = file

  const reader = new FileReader()
  reader.onload = (e) => {
    const text = e.target?.result as string
    const lines = text.split('\n').filter(line => line.trim())
    importPreview.value = lines.slice(0, 10)
    if (lines.length > 10) {
      ElMessage.info(`文件共${lines.length}行，仅显示前10行预览`)
    }
  }
  reader.readAsText(file, 'UTF-8')
}

async function handleImportSubmit() {
  if (!importFile.value || !currentWordBankId.value) {
    ElMessage.warning('请先选择要导入的文件')
    return
  }

  importLoading.value = true
  try {
    const data = (await importWordsFromFile(currentWordBankId.value, importFile.value)).data as WordImportResult
    importResult.value = data

    if (!data) {
      ElMessage.error('导入失败：服务器返回数据异常')
      return
    }

    if (data.failCount === 0) {
      ElMessage.success(`成功导入 ${data.successCount} 个单词`)
    } else if (data.successCount > 0) {
      ElMessage.warning(`导入完成：成功 ${data.successCount} 个，失败 ${data.failCount} 个`)
    } else {
      ElMessage.error(`导入失败：所有 ${data.totalCount} 行数据均无效`)
    }

    await fetchWords(1)
    await fetchList(currentPage.value)
  } catch (error: any) {
    console.error('导入失败:', error)
    ElMessage.error(error.response?.data?.message || '导入失败，请检查文件格式')
  } finally {
    importLoading.value = false
  }
}

function handleImportClose() {
  importDialogVisible.value = false
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card vocab-card">
      <div class="vocab-header">
        <div>
          <h1>公共词库管理</h1>
          <p>发布和管理所有用户可见的公共学习词库。</p>
        </div>
        <el-button type="primary" @click="handleCreate">发布新词库</el-button>
      </div>

      <el-skeleton :rows="6" animated :loading="loading">
        <template #default>
          <el-empty v-if="total === 0" description="暂无公共词库" />

          <el-table v-else :data="items" size="large" style="width: 100%">
            <el-table-column prop="name" label="词库名称" min-width="180" />
            <el-table-column prop="category" label="分类" min-width="100" />
            <el-table-column prop="wordCount" label="单词数" min-width="90" />
            <el-table-column prop="creatorName" label="创建者" min-width="120" />
            <el-table-column label="更新时间" min-width="160">
              <template #default="{ row }">
                {{ formatTime(row.updatedAt || row.createdAt) }}
              </template>
            </el-table-column>
            <el-table-column prop="description" label="描述" min-width="220" show-overflow-tooltip />
            <el-table-column label="操作" min-width="250" fixed="right">
              <template #default="{ row }">
                <div class="vocab-actions">
                  <el-button type="primary" size="small" @click="handleEdit(row)">编辑</el-button>
                  <el-button type="success" size="small" @click="handleManageWords(row)">管理单词</el-button>
                  <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="total > 0" class="vocab-pagination">
            <el-pagination
              background
              layout="prev, pager, next"
              :current-page="currentPage"
              :page-size="pageSize"
              :total="total"
              @current-change="handlePageChange"
            />
          </div>
        </template>
      </el-skeleton>
    </div>

    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="520px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="80px"
        label-position="top"
      >
        <el-form-item label="词库名称" prop="name">
          <el-input
            v-model="form.name"
            placeholder="请输入词库名称"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="词库分类" prop="category">
          <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
            <el-option
              v-for="cat in categoryOptions"
              :key="cat"
              :label="cat"
              :value="cat"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="学习语种" prop="language">
          <el-select v-model="form.language" placeholder="请选择语种" style="width: 100%">
            <el-option
              v-for="lang in languageOptions"
              :key="lang.value"
              :label="lang.label"
              :value="lang.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="词库描述" prop="description">
          <el-input
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入词库描述（可选）"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitting" @click="handleSubmit">
          {{ isEdit ? '保存修改' : '立即发布' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="wordDialogVisible"
      :title="`管理单词 - ${currentWordBankName}`"
      width="90%"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <div class="word-manage-header">
        <div class="word-manage-actions">
          <el-button type="primary" @click="handleAddWord">添加单词</el-button>
          <el-button type="success" @click="handleImportWords">批量导入TXT</el-button>
        </div>
        <span class="word-count-info">共 {{ wordTotal }} 个单词</span>
      </div>

      <el-skeleton :rows="8" animated :loading="wordLoading">
        <template #default>
          <el-empty v-if="wordTotal === 0" description="暂无单词，请点击上方按钮添加" />

          <el-table v-else :data="words" size="large" style="width: 100%">
            <el-table-column prop="english" label="英文单词" min-width="150" />
            <el-table-column prop="phonetic" label="音标" min-width="120" />
            <el-table-column prop="chinese" label="中文释义" min-width="200" show-overflow-tooltip />
            <el-table-column prop="example" label="例句" min-width="300" show-overflow-tooltip />
            <el-table-column label="操作" width="160" fixed="right">
              <template #default="{ row }">
                <div class="vocab-actions">
                  <el-button type="primary" size="small" @click="handleEditWord(row)">编辑</el-button>
                  <el-button type="danger" size="small" @click="handleDeleteWord(row)">删除</el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>

          <div v-if="wordTotal > 0" class="vocab-pagination">
            <el-pagination
              background
              layout="prev, pager, next, total"
              :current-page="wordCurrentPage"
              :page-size="wordPageSize"
              :total="wordTotal"
              @current-change="handleWordPageChange"
            />
          </div>
        </template>
      </el-skeleton>

      <template #footer>
        <el-button @click="wordDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="wordFormDialogVisible"
      :title="wordFormTitle"
      width="600px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <el-form
        ref="wordFormRef"
        :model="wordForm"
        :rules="wordRules"
        label-width="80px"
        label-position="top"
      >
        <el-form-item label="英文单词" prop="english">
          <el-input
            v-model="wordForm.english"
            placeholder="请输入英文单词"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="音标" prop="phonetic">
          <el-input
            v-model="wordForm.phonetic"
            placeholder="请输入音标（可选）"
            maxlength="100"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="中文释义" prop="chinese">
          <el-input
            v-model="wordForm.chinese"
            type="textarea"
            :rows="2"
            placeholder="请输入中文释义"
            maxlength="500"
            show-word-limit
          />
        </el-form-item>

        <el-form-item label="例句" prop="example">
          <el-input
            v-model="wordForm.example"
            type="textarea"
            :rows="3"
            placeholder="请输入例句（可选）"
            maxlength="1000"
            show-word-limit
          />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="wordFormDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="wordSubmitting" @click="handleWordSubmit">
          {{ isWordEdit ? '保存修改' : '确认添加' }}
        </el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="importDialogVisible"
      title="批量导入单词"
      width="800px"
      :close-on-click-modal="false"
      destroy-on-close
    >
      <div class="import-content">
        <el-alert
          title="文件格式说明"
          type="info"
          :closable="false"
          show-icon
          class="import-alert"
        >
          <p>请上传TXT文本文件，每行一个单词，使用Tab键分隔各字段：</p>
          <p class="format-example">英文单词[TAB]音标[TAB]中文释义[TAB]例句（可选）</p>
          <p class="format-example">示例：hello\t/həˈləʊ/\t你好\tHello, how are you?</p>
        </el-alert>

        <el-upload
          ref="uploadRef"
          drag
          :auto-upload="false"
          :limit="1"
          accept=".txt"
          :on-change="handleFileChange"
          :on-remove="() => { importFile = null; importPreview = [] }"
          class="import-upload"
        >
          <el-icon class="el-icon--upload"><Upload /></el-icon>
          <div class="el-upload__text">
            将TXT文件拖到此处，或<em>点击上传</em>
          </div>
          <template #tip>
            <div class="el-upload__tip">
              仅支持.txt格式文件，大小不超过5MB，最多支持1000行数据
            </div>
          </template>
        </el-upload>

        <div v-if="importPreview.length > 0" class="import-preview">
          <h4>文件预览（前10行）：</h4>
          <el-table :data="importPreview.map((line, index) => ({ line: index + 1, content: line }))" size="small" max-height="250">
            <el-table-column prop="line" label="行号" width="70" />
            <el-table-column prop="content" label="内容" show-overflow-tooltip />
          </el-table>
        </div>

        <div v-if="importResult" class="import-result">
          <el-alert
            :title="`导入完成：共${importResult.totalCount}行，成功${importResult.successCount}个，失败${importResult.failCount}个`"
            :type="importResult.failCount === 0 ? 'success' : (importResult.successCount > 0 ? 'warning' : 'error')"
            :closable="false"
            show-icon
          />

          <div v-if="importResult.failures && importResult.failures.length > 0" class="failure-list">
            <h4>失败详情：</h4>
            <el-table :data="importResult.failures.slice(0, 20)" size="small" max-height="200">
              <el-table-column prop="lineNumber" label="行号" width="70" />
              <el-table-column prop="content" label="内容" min-width="200" show-overflow-tooltip />
              <el-table-column prop="reason" label="原因" min-width="200" show-overflow-tooltip />
            </el-table>
            <p v-if="importResult.failures.length > 20" class="failure-more">
              还有 {{ importResult.failures.length - 20 }} 条失败记录未显示...
            </p>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button @click="handleImportClose">关闭</el-button>
        <el-button
          type="primary"
          :loading="importLoading"
          :disabled="!importFile"
          @click="handleImportSubmit"
        >
          开始导入
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<style scoped>
.vocab-card {
  max-width: 1240px;
  text-align: left;
}

.vocab-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 18px;
}

.vocab-actions {
  display: flex;
  gap: 8px;
}

.vocab-pagination {
  display: flex;
  justify-content: center;
  margin-top: 18px;
}

.word-manage-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.word-count-info {
  color: #909399;
  font-size: 14px;
}

.word-manage-actions {
  display: flex;
  gap: 10px;
}

.import-content {
  display: grid;
  gap: 18px;
}

.import-alert {
  margin-bottom: 0;
}

.import-alert :deep(p) {
  margin: 6px 0;
}

.format-example {
  font-family: 'Courier New', monospace;
  background: #f5f7fa;
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 13px;
  color: #606266;
}

.import-upload {
  width: 100%;
}

.import-upload :deep(.el-upload-dragger) {
  width: 100%;
}

.import-preview h4,
.failure-list h4 {
  margin: 0 0 10px;
  color: #303133;
  font-size: 14px;
}

.import-result {
  display: grid;
  gap: 16px;
}

.failure-more {
  margin: 8px 0 0;
  color: #909399;
  font-size: 13px;
}
</style>
