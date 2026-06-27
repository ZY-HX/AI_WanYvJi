<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import {
  getAdminAiConfig,
  updateAdminAiConfig,
  type AdminAiConfig,
  type AdminAiConfigUpdatePayload,
} from '../../api/aiConfig'

const loading = ref(false)
const submitting = ref(false)
const formRef = ref<FormInstance>()
const config = ref<AdminAiConfig | null>(null)

const form = reactive({
  baseUrl: '',
  model: '',
  apiKey: '',
  showApiKey: false,
})

const rules: FormRules<typeof form> = {
  baseUrl: [
    { required: true, message: '请输入AI服务地址', trigger: 'blur' },
    { max: 500, message: '地址长度不能超过500个字符', trigger: 'blur' },
  ],
  model: [
    { required: true, message: '请输入模型名称', trigger: 'blur' },
    { max: 100, message: '模型名称长度不能超过100个字符', trigger: 'blur' },
  ],
}

onMounted(async () => {
  await fetchConfig()
})

async function fetchConfig() {
  loading.value = true
  try {
    const result = await getAdminAiConfig()
    config.value = result
    if (result) {
      form.baseUrl = result.baseUrl || ''
      form.model = result.model || ''
      form.apiKey = ''
    }
  } finally {
    loading.value = false
  }
}

function resetForm() {
  if (config.value) {
    form.baseUrl = config.value.baseUrl || ''
    form.model = config.value.model || ''
  }
  form.apiKey = ''
  form.showApiKey = false
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) {
    return
  }

  submitting.value = true
  try {
    const payload: AdminAiConfigUpdatePayload = {
      baseUrl: form.baseUrl.trim(),
      model: form.model.trim(),
    }

    if (form.apiKey.trim()) {
      payload.apiKey = form.apiKey.trim()
    }

    await updateAdminAiConfig(payload)
    ElMessage.success('AI配置保存成功')
    await fetchConfig()
  } finally {
    submitting.value = false
  }
}

function handleClearApiKey() {
  ElMessageBox.confirm('确定要清除API Key吗？清除后用户将无法使用项目提供的AI服务', '确认清除', {
    type: 'warning',
    confirmButtonText: '确认清除',
    cancelButtonText: '取消',
  })
    .then(async () => {
      form.apiKey = ''
      submitting.value = true
      try {
        await updateAdminAiConfig({ apiKey: null })
        ElMessage.success('API Key已清除')
        await fetchConfig()
      } finally {
        submitting.value = false
      }
    })
    .catch(() => {})
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card ai-config-card">
      <div class="page-header">
        <div>
          <h1>AI 服务配置</h1>
          <p>配置AI服务的API Key、服务地址和模型，用于用户端的AI阅读强化功能。</p>
        </div>

        <el-tag :type="config?.apiKeyConfigured ? 'success' : 'danger'" effect="dark" size="large">
          {{ config?.apiKeyConfigured ? '已配置 API Key' : '未配置 API Key' }}
        </el-tag>
      </div>

      <el-skeleton :rows="8" animated :loading="loading">
        <template #default>
          <el-card shadow="never" class="ai-config-form-card">
            <el-alert
              v-if="!config?.apiKeyConfigured"
              title="当前未配置API Key，用户端将无法使用项目提供的AI服务"
              type="warning"
              :closable="false"
              show-icon
              class="ai-config-warning"
            />

            <el-form
              ref="formRef"
              :model="form"
              :rules="rules"
              label-width="140px"
              label-position="right"
              class="ai-config-form"
            >
              <el-form-item label="AI 服务地址" prop="baseUrl">
                <el-input
                  v-model="form.baseUrl"
                  placeholder="例如：https://api.openai.com/v1"
                  maxlength="500"
                  show-word-limit
                />
                <div class="ai-config-tip">支持OpenAI兼容接口的任意服务商地址</div>
              </el-form-item>

              <el-form-item label="模型名称" prop="model">
                <el-input
                  v-model="form.model"
                  placeholder="例如：gpt-4o-mini / glm-4-flash / qwen-plus"
                  maxlength="100"
                  show-word-limit
                />
                <div class="ai-config-tip">根据所选服务商填写对应的模型标识</div>
              </el-form-item>

              <el-form-item label="API Key">
                <div class="ai-api-key-wrapper">
                  <el-input
                    v-model="form.apiKey"
                    :type="form.showApiKey ? 'text' : 'password'"
                    placeholder="请输入API Key（留空表示不修改）"
                    show-password
                    @change="() => { form.showApiKey = false }"
                  />
                  <el-button
                    v-if="config?.apiKeyConfigured"
                    type="danger"
                    plain
                    @click="handleClearApiKey"
                  >
                    清除现有Key
                  </el-button>
                </div>
                <div class="ai-config-tip">
                  <span v-if="config?.apiKeyConfigured">
                    当前已配置：{{ config.apiKeyMasked || '****' }} （留空表示不修改）
                  </span>
                  <span v-else>输入新的API Key以更新配置</span>
                </div>
              </el-form-item>

              <el-form-item>
                <div class="ai-config-actions">
                  <el-button @click="resetForm">重置</el-button>
                  <el-button type="primary" :loading="submitting" @click="handleSubmit">
                    保存配置
                  </el-button>
                </div>
              </el-form-item>
            </el-form>
          </el-card>

          <el-card shadow="never" class="ai-config-info-card">
            <template #header>
              <span>配置说明</span>
            </template>
            <div class="ai-config-info">
              <div class="ai-config-info__item">
                <strong>使用场景</strong>
                <p>此配置用于用户端「AI阅读强化」功能中的"项目提供"模式。当管理员配置了有效的API Key后，用户可以选择使用项目提供的Key来生成文章。</p>
              </div>
              <div class="ai-config-info__item">
                <strong>安全提示</strong>
                <p>API Key是敏感信息，请妥善保管。配置后会存储在数据库中，不会暴露给前端用户。建议定期更换API Key。</p>
              </div>
              <div class="ai-config-info__item">
                <strong>优先级规则</strong>
                <p>如果用户选择"我自己提供"模式并输入了自己的API Key，则优先使用用户的Key；否则使用此处配置的项目默认Key。</p>
              </div>
            </div>
          </el-card>
        </template>
      </el-skeleton>
    </div>
  </div>
</template>

<style scoped>
.ai-config-card {
  max-width: 960px;
  text-align: left;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 24px;
}

.page-header h1 {
  margin: 0 0 8px;
  font-size: 26px;
  color: #1f2d3d;
}

.page-header p {
  margin: 0;
  color: #5b6475;
  font-size: 14px;
}

.ai-config-warning {
  margin-bottom: 20px;
}

.ai-config-form-card {
  margin-bottom: 20px;
  border-radius: 16px;
}

.ai-config-form {
  padding: 20px 0;
}

.ai-config-tip {
  margin-top: 6px;
  color: #909399;
  font-size: 13px;
  line-height: 1.6;
}

.ai-api-key-wrapper {
  display: flex;
  gap: 12px;
  width: 100%;
}

.ai-api-key-wrapper .el-input {
  flex: 1;
}

.ai-config-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.ai-config-info-card {
  border-radius: 16px;
}

.ai-config-info {
  display: grid;
  gap: 20px;
}

.ai-config-info__item strong {
  display: block;
  margin-bottom: 8px;
  color: #1f2d3d;
  font-size: 15px;
}

.ai-config-info__item p {
  margin: 0;
  color: #5b6475;
  font-size: 14px;
  line-height: 1.7;
}

@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
  }

  .ai-api-key-wrapper {
    flex-direction: column;
  }

  .ai-config-actions {
    flex-direction: column;
  }

  .ai-config-actions .el-button {
    width: 100%;
  }
}
</style>
