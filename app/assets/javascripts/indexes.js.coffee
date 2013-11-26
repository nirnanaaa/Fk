canvas = document.getElementById('img')
context = canvas.getContext('2d')
window.addEventListener('resize', resizeCanvas, false);

resizeCanvas = ->

  console.log("resize")
  
  
imageObj = new Image();

imageObj.onload = ->
  canvas.width = window.innerWidth
  canvas.height= window.innerHeight
  context.drawImage(imageObj, 0,0);
      
imageObj.src = '/assets/website_under_construction1.png';
