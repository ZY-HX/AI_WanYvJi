<script setup lang="ts">
import { reactive, ref } from 'vue'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { publishAnnouncement } from '../../api/notifications'

const formRef = ref<FormInstance>()
const submitting = ref(false)

const form = reactive({
  title: '',
  content: '',
})

const rules: FormRules<typeof form> = {
  title: [
    { required: true, message: '请输入公告标题', trigger: 'blur' },
    { max: 100, message: '标题长度不能超过100个字符', trigger: 'blur' },
  ],
  content: [
    { required: true, message: '请输入公告内容', trigger: 'blur' },
    { max: 1000, message: '内容长度不能超过1000个字符', trigger: 'blur' },
  ],
}

function resetForm() {
  form.title = ''
  form.content = ''
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) {
    return
  }
  if (!form.title.trim() || !form.content.trim()) {
    ElMessage.warning('公告标题和内容不能为空白字符')
    return
  }

  const confirmed = await ElMessageBox.confirm(
    '确认发布此公告？发布后将发送给所有用户',
    '发布确认',
    {
      confirmButtonText: '确认发布',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).catch(() => false)

  if (!confirmed) {
    return
  }

  submitting.value = true
  try {
    const result = await publishAnnouncement({
      title: form.title.trim(),
      content: form.content.trim(),
    })
    console.log('发布公告成功:', result)
    ElMessage.success('公告发布成功')
    resetForm()
    formRef.value?.resetFields()
  } catch (error: any) {
    console.error('发布公告失败详情:', error)
    console.error('响应数据:', error.response?.data)
    console.error('状态码:', error.response?.status)
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="page-placeholder">
    <div class="placeholder-card announcement-card">
      <div class="page-header">
        <div>
          <h1>发布系统公告</h1>
          <p>向所有用户发送系统公告，用户将在站内消息中收到通知。</p>
        </div>
      </div>

      <div class="form-container">
        <el-form
          ref="formRef"
          :model="form"
          :rules="rules"
          label-width="100px"
          size="large"
        >
          <el-form-item label="公告标题" prop="title">
            <el-input
              v-model="form.title"
              maxlength="100"
              show-word-limit
              placeholder="请输入公告标题"
            />
          </el-form-item>

          <el-form-item label="公告内容" prop="content">
            <el-input
              v-model="form.content"
              type="textarea"
              :rows="10"
              maxlength="1000"
              show-word-limit
              placeholder="请输入公告内容"
            />
          </el-form-item>

          <el-form-item>
            <el-button type="primary" :loading="submitting" @click="handleSubmit">
              发布公告
            </el-button>
            <el-button @click="resetForm">重置</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<style scoped>
.announcement-card {
  max-width: 900px;
  text-align: left;
}

.page-header {
  margin-bottom: 30px;
}

.page-header h1 {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 8px;
}

.page-header p {
  font-size: 14px;
  color: #909399;
  margin: 0;
}

.form-container {
  background-color: #fff;
  padding: 30px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
}
</style>
