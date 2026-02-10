<template>
  <div class="clearfix news-detail-middle-page-scroll">
    <div v-show="spinning">
      <div style="width:210px;margin:100px auto">
        <a-spin :tip="tip"  size="large" :spinning="spinning">
          <a-icon slot="indicator" type="loading" spin />
        </a-spin>
      </div>
      <div style="width: max-content;;margin:100px auto">

<!-- 原文标题：<span v-html="decodeURIComponent($route.query.title)"></span> <br> -->
        原文链接：{{$route.query.id}} <a :href="$route.query.id" target="_blank">点击跳转</a>
      </div>
    </div>
    <div style="position: absolute;right:50vw;top:0" v-show="isBloomBerg">
      <a-button type="danger" @click="report_err">报错</a-button>
    </div>
    <div style="height:100vh;overflow-y:scroll;overflow-x: hidden;" v-show="showBloomberg">
      <div v-for="(l,idx) in url" :key="idx">
        <img :src="l" alt="" :draggable="false">
      </div>
    </div>
    <div v-show="showTwitter">
      <div
          style="max-width: 600px;height:100vh;padding:0 10px;background-color: rgba(0, 0, 0, 0);margin: 0 auto;border-left: 1px solid rgb(231, 219, 219);border-right: 1px solid rgb(226, 218, 218);overflow: auto;">
          <div style="display: flex;">
              <div style="width: 40px;height: 40px;margin-right: 12px;">
                  <img width="40px" :src="twitter_data.type" alt="推主头像">
              </div>
              <div>
                  <span>{{twitter_data.author}}</span> <br>
                  <span>@{{twitter_data.author_id}}</span>
              </div>
          </div>
          <div style="margin:10px 0">
            {{twitter_data.title}}
            <br>
              {{twitter_data.content}}
          </div>
          <div >
            <img width="100%" :src="twitter_data.link" alt="" style="border-radius: 16px;">
          </div>
          <div>
            {{twitter_data.content_time}}
          </div>
          <div>
            <a :href="this.$route.query.id" target="_blank">原文链接：{{this.$route.query.id}}</a> 
          </div>
      </div>
    </div>
    <div v-show="showReuter" class="reuter" style="font-size: 18px;padding-left: 300px;overflow: auto;height: 100vh;width: 80%;">

    </div>
    <div v-show="showCaixin" class="caixin" style="overflow: auto;height: 100vh;width: 60vw;padding: 20px 20px 0 0;margin: 0 auto;font-size: 18px;font-family: 微软雅黑;color: #4a4a4a;line-height: 34px;">

    </div>
    <div v-show="showJnz" class="jnz" style="overflow: auto;height: 100vh;width: 60vw;padding: 20px 20px 0 0;margin: 0 auto;font-size: 18px;font-family: 微软雅黑;color: #4a4a4a;line-height: 34px;">

    </div>   
    <div v-show="showBloombergMobie" class="bloomberg_mobie" style="font-size: 18px;padding-left: 300px;overflow: auto;height: 100vh;width: 80%;white-space: pre-wrap;">

    </div>     
    <div class="watermark" :style="{ backgroundImage: bgurl }"></div>
    <div class="watermark" style="margin-top:50px" :style="{ backgroundImage: bgurl2 }"></div>
  </div>
</template>

<script>
import watermark from "@/plugin/watermark";
import {decryptImg} from '../utils/util'
import { mapState } from 'vuex';
  export default {
    name: 'Bloomberg',
    data(){
      return{
        spinning:true,
        url:[],
        waiting:0,
        twitter_data:{},
        bgurl: '',
        bgurl2: '',
        isBloomBerg:false,
        showTwitter:false,
        showReuter:false,
        showBloomberg:false,
        showCaixin:false,
        showJnz:false,
        showBloombergMobie:false,
      }
    },
    computed:{
      tip(){
        // return `L o a d i n g 还 有 ${this.waiting} 人 排 队 . . .`
        return 'L o a d i n g . . .'
      },
      ...mapState(['userInfo']),
      watermarkPermisson() {
        return this.userInfo.roles.find((item) => item.rolename === '水印')
      },   
    },
    created(){
      let link = this.$route.query.id
      if(link && link.includes('blinks.bloomberg')){
        this.isBloomBerg = true
      }     
    },
    mounted(){
      let link = this.$route.query.id
      if(link && !link.includes('twitter.com') && !link.includes('reuters')){
        document.oncontextmenu = function(){
          return false;
        }
      }
      let mark_color = '#1890FF'
      if(this.isBloomBerg){
        mark_color = 'white'
      }
      if (this.watermarkPermisson && this.$route.meta.haveMark) {
        let markName = this.userInfo.real_name + ' 内部资料'
        this.bgurl = 'url(' + watermark(markName , mark_color , '12') + ')'
        this.bgurl2 = 'url(' + watermark('请勿外传' , mark_color , '12') + ')'        
      } else {
        this.bgurl = ''
        this.bgurl2 = ''
      }
      this.getBloombergPic()
    },
    methods:{
      getBloombergPic(){
        let link = this.$route.query.id
        if(!link){
          this.$message.error('没有链接！')
          return
        }
        let params = {
          link: this.$route.query.id
        }
        let record_id = this.$route.query.record_id
        if(record_id){
          params.id = record_id
        }
        this.$request({
          url:'/v1/news/bloomberg',
          method:'get',
          params,
        }).then(async (res)=>{
          let data = res.data.data
          if(data && data.status === 'ok'){
            this.timer && clearInterval(this.timer)
            this.spinning = false
            if(link.includes('twitter.com')){
              this.showTwitter = true
              this.twitter_data = data.data
            }else if(link.includes('reuters')){
              this.showReuter = true
              let reuter = document.querySelector('.reuter')
              reuter.innerHTML = res.data.data.html
            }else if(link.includes('blinks.bloomberg')){
              this.showBloomberg = true
              // this.url = data.url
              let urls = data.url
              for(let i=0;i<urls.length;i++){
                let l = urls[i]
                let temp = l.split('/')
                if(temp.length>0){
                  let img_name = temp[temp.length-1]
                  if(img_name.slice(0,2) == 'jm'){
                    let decryptedImageUrl = await decryptImg(l)
                    this.url.push(decryptedImageUrl)
                  }else{
                    this.url.push(l)
                  }
                }                
              }
            }else if(link.includes('caixin') || link.includes('baiinfo')){
              this.showCaixin = true
              let caixin = document.querySelector('.caixin')
              caixin.innerHTML = res.data.data.html
              // reuter.querySelector('body').style.fontSize="16px"           
            }else if(link.includes('zzb.jddglobal')){
              this.showJnz = true
              let jnz = document.querySelector('.jnz')
              let d = JSON.parse(data.data)
              let title = '<h1>' + d.data.mainTitle + '</h1>'
              let content = d.data.content 
              jnz.innerHTML = title + content         
            }else if(link.includes('articles.zsxq.com')){  
              // 知识星球
              this.showJnz = true
              let jnz = document.querySelector('.jnz')
              jnz.innerHTML = res.data.data.html             
            }else if(link.includes('api.zsxq.com/v2/files')){
              // 知识星球文件下载
              this.showJnz = true
              let jnz = document.querySelector('.jnz')
              let file_name = this.$route.query.title
              if (res.data.data.html.includes('upload')) {
                if(file_name && file_name.includes('.pdf')){
                  jnz.innerHTML =  `点击链接下载文件：<a download target="_blank" href="${res.data.data.html}">${file_name} </a>`              
                }else{
                  jnz.innerHTML =  `点击链接下载文件：<a download href="${res.data.data.html}">${file_name} </a>`
                }
              }else{
                jnz.innerHTML =  '星球源文件被删除或被修改！无法下载！'
              }
            }else if(link.includes('www.cls.cn') || link.includes('acecamp')){
              this.showJnz = true
              let jnz = document.querySelector('.jnz')
              jnz.innerHTML = res.data.data.html
            }else{
              this.showBloombergMobie = true
              let bloomberg_mobie = document.querySelector('.bloomberg_mobie')
              bloomberg_mobie.innerHTML = res.data.data.html
            }    
          }else{
            // this.waiting = data.waiting
            if(!this.timer){
              this.timer = setInterval(()=>{
                this.getBloombergPic()
              },2000)
            }
          }
        }).catch((res)=>{
          this.$message.error('获取失败')
        })
      },
      report_err(){
        this.$request({
          url:'/v1/news/bloomberg/report',
          method:'get',
          params:{
            link:this.$route.query.id
          }
        }).then((res)=>{
          if(res.code == 200){
            this.$message.success('上报成功')
            this.url = []
            this.spinning = true
            this.getBloombergPic()
            this.timer = setInterval(()=>{
              this.getBloombergPic()
            },2000)            
          }
        })
      }
    }
  }
</script>

<style scoped>
.clearfix:after {
  visibility: hidden;
  display: block;
  font-size: 0;
  content: " ";
  clear: both;
  height: 0;
}
.watermark {
  z-index: 9999;
  position: absolute;
  left: 0px;
  top: 0px;
  width: calc(100vw - 0px);
  height: calc(100vh - 0px);
  background-size: 332px;
  pointer-events: none;
  background-repeat: repeat;
}
::v-deep .caixin em{
  font-style: normal !important; 
}
::v-deep .reuter .newsitem .storyContentzh p {
    font-family: sans-serif !important;
}

::v-deep .caixin .content{
    background-color: #eaf0f2;
    border: 1px solid #95b2c0;
    line-height: 24px;
    margin: 6px 0;
    overflow: auto;
    padding: 15px;
}
::v-deep .caixin .pb-\[20px\] {
    padding-bottom: 20px;
}
::v-deep .caixin .mt-\[20px\] {
    margin-top: 20px;
}
::v-deep .caixin p{
    text-indent: 2em;
    text-align: left;
}
::v-deep .caixin .tips {
    border-bottom: 1px dotted #e5e5e5;
    color: #9e9e9f;
}
::v-deep .caixin .text-size-14 {
    font-size: 14px;
}

::v-deep .caixin .article-title{
    border-bottom: 1px dotted #e5e5e5;
    color: red;
}
::v-deep .caixin .text-size-24 {
    font-size: 24px;
}
::v-deep .caixin .text-center {
    text-align: center;
}
::v-deep .caixin .pb-\[10px\] {
    padding-bottom: 10px;
}
::v-deep .caixin .mb-\[10px\] {
    margin-bottom: 10px;
}
/* 重置所有滚动条相关样式 */
.news-detail-middle-page-scroll div{
  overflow-y: auto;
  scrollbar-color: #e8eaed #fff;
  scrollbar-width: 8px;
  scrollbar-width: 15px;
}
/* .scroll-y-bar-default{
  overflow-y: auto;
  scrollbar-color: #e8eaed #fff;
  scrollbar-width: 8px;
  scrollbar-width: 15px;
} */
::v-deep .jnz img{
  width: 100%;
}
</style>