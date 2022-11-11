function scrollToBottom(id){
   var element = document.getElementById(id);
   element.scrollTop = element.scrollHeight - element.clientHeight;
}

document.addEventListener('phx:update', phxUpdateListener);

function phxUpdateListener(_event) {
  scrollToBottom('terminal');
}
