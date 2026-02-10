if(news && (news.external === 'bloomberg' || news.external === 'bloomberg_test'  || news.external === 'reuters' || news.external === 'twitter' || news.external === 'caixin' || news.external === 'jnz' || news.external === 'zsxq' || news.external === 'product' || news.external === 'pzb' || news.external === 'acecamp') && store.state.userInfo.roles.findIndex((r)=> r.value === 'screenshot') !== -1){
    if(news.external === 'jnz'){
      news.link = encodeURIComponent(news.link)
    }
    let record_id = ''
    if(news && news.data_id){
      record_id = news.data_id
    }else if(news && news.id){
      record_id = news.id
    }
    let path = `/bloomberg?id=${news.link}&record_id=${record_id}`
    if(news.external === 'zsxq'){
      path += `&title=${news.title}`
    }
    openNewPage(path)
  }