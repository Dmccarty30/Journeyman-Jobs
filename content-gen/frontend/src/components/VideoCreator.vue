<script setup lang="ts">
import { ref, computed } from 'vue'
import { useVideoGeneration } from '../composables/useVideoGeneration'
import type { VideoModel, VideoDuration } from '../types/video'

const emit = defineEmits<{
  videoCreated: [videoId: string]
}>()

const { createVideo, loading, error } = useVideoGeneration()

const prompt = ref('')
const model = ref<VideoModel>('sora-2')
const seconds = ref<VideoDuration>(4)
const size = ref('1280x720')
const inputReference = ref<File | undefined>()
const previewUrl = ref<string | null>(null)

const MAX_PROMPT_LENGTH = 500
const promptLength = computed(() => prompt.value.length)

const resolutionOptions = [
  { value: '1280x720', label: 'HD 720p Landscape (1280x720)' },
  { value: '720x1280', label: 'HD 720p Portrait (720x1280)' },
  { value: '1024x1024', label: 'Square (1024x1024)' },
  { value: '1920x1080', label: 'Full HD (1920x1080)' }
]

const promptTemplates = [
  {
    label: 'Cinematic Scene',
    template: 'Wide shot of [subject] in [setting], golden hour lighting, slow camera pan'
  },
  {
    label: 'Product Showcase',
    template: 'Close-up of [product] on marble surface, soft studio lighting, subtle rotation'
  },
  {
    label: 'Nature Scene',
    template: 'Aerial view of [natural subject] in [environment], sunset, gentle movement'
  }
]

const handleFileUpload = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]

  if (file) {
    inputReference.value = file
    previewUrl.value = URL.createObjectURL(file)
  }
}

const removeReference = () => {
  inputReference.value = undefined
  if (previewUrl.value) {
    URL.revokeObjectURL(previewUrl.value)
    previewUrl.value = null
  }
}

const useTemplate = (template: string) => {
  prompt.value = template
}

const handleSubmit = async () => {
  if (!prompt.value.trim()) {
    return
  }

  try {
    const video = await createVideo({
      prompt: prompt.value,
      model: model.value,
      seconds: seconds.value,
      size: size.value,
      input_reference: inputReference.value
    })

    emit('videoCreated', video.id)

    // Reset form
    prompt.value = ''
    removeReference()
  } catch (err) {
    console.error('Failed to create video:', err)
  }
}
</script>

<template>
  <div class="video-creator">
    <h2>Create Video</h2>

    <!-- Prompt Templates -->
    <div class="templates">
      <label>Quick Templates:</label>
      <div class="template-buttons">
        <button
          v-for="template in promptTemplates"
          :key="template.label"
          type="button"
          class="template-btn"
          @click="useTemplate(template.template)"
        >
          {{ template.label }}
        </button>
      </div>
    </div>

    <!-- Prompt Input -->
    <div class="form-group">
      <label for="prompt">
        Prompt
        <span class="char-count">{{ promptLength }}/{{ MAX_PROMPT_LENGTH }}</span>
      </label>
      <textarea
        id="prompt"
        v-model="prompt"
        :maxlength="MAX_PROMPT_LENGTH"
        placeholder="Describe the video you want to generate..."
        rows="4"
      ></textarea>
    </div>

    <!-- Model Selection -->
    <div class="form-group">
      <label for="model">Model</label>
      <select id="model" v-model="model">
        <option value="sora-2">Sora 2 (Fast, Standard Quality)</option>
        <option value="sora-2-pro">Sora 2 Pro (Slower, High Quality)</option>
      </select>
    </div>

    <!-- Duration and Resolution -->
    <div class="form-row">
      <div class="form-group">
        <label for="seconds">Duration</label>
        <select id="seconds" v-model.number="seconds">
          <option :value="4">4 seconds</option>
          <option :value="8">8 seconds</option>
          <option :value="12">12 seconds</option>
        </select>
      </div>

      <div class="form-group">
        <label for="size">Resolution</label>
        <select id="size" v-model="size">
          <option
            v-for="option in resolutionOptions"
            :key="option.value"
            :value="option.value"
          >
            {{ option.label }}
          </option>
        </select>
      </div>
    </div>

    <!-- Reference Image Upload -->
    <div class="form-group">
      <label for="reference">Reference Image (Optional)</label>
      <input
        id="reference"
        type="file"
        accept="image/*"
        @change="handleFileUpload"
      />
      <div v-if="previewUrl" class="preview">
        <img :src="previewUrl" alt="Reference preview" />
        <button type="button" class="remove-btn" @click="removeReference">Remove</button>
      </div>
    </div>

    <!-- Error Message -->
    <div v-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Content Guidelines -->
    <div class="guidelines">
      <strong>Content Guidelines:</strong>
      <ul>
        <li>No copyrighted characters or music</li>
        <li>No real people or public figures</li>
        <li>Content must be appropriate for all audiences</li>
      </ul>
    </div>

    <!-- Submit Button -->
    <button
      type="button"
      class="submit-btn"
      :disabled="!prompt.trim() || loading"
      @click="handleSubmit"
    >
      {{ loading ? 'Creating Video...' : 'Generate Video' }}
    </button>
  </div>
</template>

<style scoped>
.video-creator {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
}

h2 {
  margin-top: 0;
  margin-bottom: 1.5rem;
  font-size: 1.8rem;
  font-weight: bold;
  color: black;
}

.templates {
  margin-bottom: 1.5rem;
}

.templates label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: black;
}

.template-buttons {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.template-btn {
  padding: 0.5rem 1rem;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  color: black;
  transition: all 0.2s;
}

.template-btn:hover {
  background: #f5f5f5;
  border-color: #999;
}

.form-group {
  margin-bottom: 1.5rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: black;
}

.char-count {
  float: right;
  font-weight: normal;
  font-size: 0.9rem;
  color: #666;
}

textarea,
select,
input[type="file"] {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  font-family: inherit;
  font-size: 1rem;
  color: black;
  background: white;
  box-sizing: border-box;
}

textarea {
  resize: vertical;
  min-height: 100px;
}

textarea:focus,
select:focus {
  outline: none;
  border-color: #666;
}

.preview {
  margin-top: 1rem;
  position: relative;
}

.preview img {
  max-width: 200px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.remove-btn {
  margin-top: 0.5rem;
  padding: 0.25rem 0.5rem;
  background: white;
  border: 1px solid #ccc;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  color: black;
}

.remove-btn:hover {
  background: #f5f5f5;
}

.error-message {
  padding: 1rem;
  margin-bottom: 1rem;
  background: #fee;
  border: 1px solid #fcc;
  border-radius: 4px;
  color: #c00;
}

.guidelines {
  padding: 1rem;
  margin-bottom: 1.5rem;
  background: #f9f9f9;
  border: 1px solid #e0e0e0;
  border-radius: 4px;
  font-size: 0.9rem;
  color: black;
}

.guidelines strong {
  display: block;
  margin-bottom: 0.5rem;
}

.guidelines ul {
  margin: 0;
  padding-left: 1.5rem;
}

.guidelines li {
  margin-bottom: 0.25rem;
}

.submit-btn {
  width: 100%;
  padding: 1rem;
  background: black;
  color: white;
  border: none;
  border-radius: 4px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}

.submit-btn:hover:not(:disabled) {
  background: #333;
}

.submit-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}
</style>
