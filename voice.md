  <div class="star-icon-wrapper">
    <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor">
      <path d="M12 2L14.39 9.61L22 12L14.39 14.39L12 22L9.61 14.39L2 12L9.61 9.61L12 2Z" />
    </svg>
  </div>


              .star-icon-wrapper { 
  width: 24px; 
  height: 24px; 
  display: flex; 
  justify-content: center; 
  align-items: center; 
  color: var(--text-sub); 
  transition: color 0.3s; 
  margin-right: 8px; 
}
.status-bar.processing .star-icon-wrapper { 
  color: var(--accent-color); 
  animation: star-spin 4s linear infinite; 
}
.status-text { 
  font-size: 15px; 
  font-weight: 600; 
  color: var(--text-main); 
  transition: all 0.3s; 
}
.status-bar.processing .status-text {
  background-image: linear-gradient(90deg, var(--primary-color), var(--accent-color), #ec4899, var(--primary-color));
  background-size: 300% 100%; 
  color: transparent; -webkit-background-clip: text; 
  background-clip: text;
  animation: shimmer-text 4s infinite linear;
}
.step-badge { 
  font-size: 10px; 
  font-weight: 700; 
  padding: 3px 8px; 
  border-radius: 12px; 
  background: #f1f5f9; color: var(--text-sub); 
  opacity: 0; transform: translateX(10px); 
  transition: all 0.4s; 
  margin-left: auto; 
  margin-right: 40px; /* 让开关闭按钮位置 */ 
}
.step-badge.show { 
  opacity: 1; 
  transform: translateX(0); 
  background: var(--primary-light); 
  color: var(--primary-color); 
}