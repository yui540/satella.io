var Satella,fs,vs;(function(){vs="attribute vec3 position; attribute vec4 color; attribute vec2 textureCoord; uniform   mat4 mvpMatrix; varying   vec4 vColor; varying   vec2 vTextureCoord; void main(void){ vColor        = color; vTextureCoord = textureCoord; gl_Position   = mvpMatrix * vec4(position, 1.0); }";fs="precision mediump float; uniform sampler2D texture; uniform int premultipliedAlpha; varying vec4      vColor; varying vec2      vTextureCoord; void main(void){ vec4 smpColor = texture2D(texture, vTextureCoord); vec4 color = vec4(smpColor.rgb * vColor.rgb, smpColor.a * vColor.a); color = vec4(color.rgb * color.a, color.a); gl_FragColor  = color; }";Satella=(function(){function b(c){this.app_json={};this.app_state={};this.app=c.app;this.webgl=null;this.width=c.width;this.height=c.height;this.resource={};this.texture={};this.timer=null;this.max=0;this.listeners={}}b.prototype.on=function(c,d){if(this.listeners[c]===void 0){this.listeners[c]=[]}return this.listeners[c].push(d)};b.prototype.emit=function(f,h){var i,d,c,g,e;g=this.listeners[f];if(g===void 0){return}e=[];for(d=0,c=g.length;d<c;d++){i=g[d];e.push(i(h))}return e};b.prototype.copy=function(c){return JSON.parse(JSON.stringify(c))};b.prototype.len=function(e){var d,c,f;d=0;for(c in e){f=e[c];d++}return d};b.prototype.diff=function(d,c){if(d>c){return d-c}else{return -(c-d)}};b.prototype.createShader=function(d,c){var e;e=null;if(d==="vs"){e=this.gl.createShader(this.gl.VERTEX_SHADER)}else{if(d==="fs"){e=this.gl.createShader(this.gl.FRAGMENT_SHADER)}}this.gl.shaderSource(e,c);this.gl.compileShader(e);if(this.gl.getShaderParameter(e,this.gl.COMPILE_STATUS)){return e}else{return console.error(this.gl.getShaderInfoLog(e))}};b.prototype.createProgramObj=function(e,c){var d;d=this.gl.createProgram();this.gl.attachShader(d,e);this.gl.attachShader(d,c);this.gl.linkProgram(d);if(this.gl.getProgramParameter(d,this.gl.LINK_STATUS)){this.gl.useProgram(d);return d}else{return console.error(this.gl.getProgramInfoLog(d))}};b.prototype.createVbo=function(c){var d;d=this.gl.createBuffer();this.gl.bindBuffer(this.gl.ARRAY_BUFFER,d);this.gl.bufferData(this.gl.ARRAY_BUFFER,new Float32Array(c),this.gl.STATIC_DRAW);this.gl.bindBuffer(this.gl.ARRAY_BUFFER,null);return d};b.prototype.createIbo=function(d){var c;c=this.gl.createBuffer();this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER,c);this.gl.bufferData(this.gl.ELEMENT_ARRAY_BUFFER,new Int16Array(d),this.gl.STATIC_DRAW);this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER,null);return c};b.prototype.render=function(){this.webgl=document.createElement("canvas");this.webgl.width=this.width;this.webgl.height=this.height;this.gl=this.webgl.getContext("webgl",{preserveDrawingBuffer:true});this.app.appendChild(this.webgl);this.initShader();this.initProgramObj();this.initAttribute();this.initUniform();this.initMatrix();this.depth();return this.loadJSON()};b.prototype.initShader=function(){this.v_shader=this.createShader("vs",vs);return this.f_shader=this.createShader("fs",fs)};b.prototype.initProgramObj=function(){return this.prg=this.createProgramObj(this.v_shader,this.f_shader)};b.prototype.initAttribute=function(){this.attLocation={position:this.gl.getAttribLocation(this.prg,"position"),color:this.gl.getAttribLocation(this.prg,"color"),texture:this.gl.getAttribLocation(this.prg,"textureCoord")};return this.attStride={position:3,color:4,texture:2}};b.prototype.initUniform=function(){return this.uniLocation={mvpMatrix:this.gl.getUniformLocation(this.prg,"mvpMatrix"),texture:this.gl.getUniformLocation(this.prg,"texture"),premultipliedAlpha:this.gl.getUniformLocation(this.prg,"premultipliedAlpha")}};b.prototype.initMatrix=function(){this.m=new a();this.m_matrix=this.m.identity(this.m.create());this.v_matrix=this.m.identity(this.m.create());this.p_matrix=this.m.identity(this.m.create());this.tmp_matrix=this.m.identity(this.m.create());return this.mvp_matrix=this.m.identity(this.m.create())};b.prototype.depth=function(){this.gl.enable(this.gl.DEPTH_TEST);return this.gl.depthFunc(this.gl.LEQUAL)};b.prototype.setAttribute=function(e,c,d){this.gl.bindBuffer(this.gl.ARRAY_BUFFER,e);this.gl.enableVertexAttribArray(c);return this.gl.vertexAttribPointer(c,d,this.gl.FLOAT,false,0,0)};b.prototype.createTexture=function(d,f){var e,c;e=this.gl[f];c=this.gl.createTexture();this.gl.bindTexture(this.gl.TEXTURE_2D,c);this.gl.texImage2D(this.gl.TEXTURE_2D,0,this.gl.RGBA,this.gl.RGBA,this.gl.UNSIGNED_BYTE,d);this.gl.texParameteri(this.gl.TEXTURE_2D,this.gl.TEXTURE_MAG_FILTER,this.gl.LINEAR);this.gl.texParameteri(this.gl.TEXTURE_2D,this.gl.TEXTURE_MIN_FILTER,e);this.gl.generateMipmap(this.gl.TEXTURE_2D);this.gl.bindTexture(this.gl.TEXTURE_2D,null);return c};b.prototype.loadJSON=function(){var c;c=new XMLHttpRequest();c.open("GET","satella-sdk/lib/app.json");c.onreadystatechange=(function(d){return function(){if(c.readyState===4){d.app_json=JSON.parse(c.responseText);d.loadResource();return d.initAppState()}}})(this);return c.send()};b.prototype.loadResource=function(){var g,c,i,f,e,k,h,d;i=this.app_json.layer;h=[];for(g=0,f=i.length;g<f;g++){c=i[g];e=c.name;d="satella-sdk/"+c.url;k=c.quality;h.push(this.loadOne(e,d,k))}return h};b.prototype.loadOne=function(f,e,g){var d,c;c=this.app_json.layer.length;d=new Image();d.src=e;return d.onload=(function(h){return function(i){h.resource[f]=d;h.texture[f]=h.createTexture(d,g);if(h.len(h.texture)>=c){h.loop();return h.emit("load")}}})(this)};b.prototype.initAppState=function(){var d,h,c,g,e,f;this.app_state={play:false,time:0,keyframes:false,scale:1,position:{x:0.5,y:0.5},parameter:{}};g=this.app_json.parameter;e=[];for(d in g){h=g[d];f=h.type;c={};if(f===4){c={x:0.5,y:0.5}}else{c={x:0.5}}e.push(this.app_state.parameter[d]=c)}return e};b.prototype.blendType=function(c){switch(c){case 0:this.gl.blendEquationSeparate(this.gl.FUNC_ADD,this.gl.FUNC_ADD);return this.gl.blendFuncSeparate(this.gl.ONE,this.gl.ONE_MINUS_SRC_ALPHA,this.gl.ONE,this.gl.ONE_MINUS_SRC_ALPHA);case 1:return this.gl.blendFunc(this.gl.SRC_ALPHA,this.gl.ONE)}};b.prototype.getMiddle=function(t,g){var C,d,c,l,u,s,o,h,D,B,r,q,k,m,A,z,p,w,v,n,f,e;m=this.app_state.time;h=t.length;if(h===0){r={};if(g===4){r={x:0.5,y:0.5}}else{r={x:0.5}}return r}else{if(h===1){return t[0]}}for(u=s=0,k=h-2;0<=k?s<=k:s>=k;u=0<=k?++s:--s){A=t[u].time;z=t[u+1].time;C=m-A;q=z-A;w=t[u].x;f=t[u].y;v=t[u+1].x;e=t[u+1].y;if(A<=m&&z>=m){B=C/q;d=this.diff(v,w)*B;p=w+d;c=0;n=0;D={};D.x=p;if(f!==void 0){c=this.diff(e,f)*B;n=f+c;D.y=n}return D}}l=t[0].time;o=t[h-1].time;if(m<l){return t[0]}else{if(m>o){return t[h-1]}}};b.prototype.getMove=function(l){var k,j,i,h,g,e,d,c,f,p,q,o,n;g=this.copy(this.app_json.layer[l].move);p=this.app_json.layer[l].parameter;i=this.app_state.keyframes;for(e in p){f=p[e].move;o=this.app_state.parameter[e].x;n=this.app_state.parameter[e].y;k=d=0;j=c=0;if(f===void 0){continue}if(i!==false){q=this.app_json.keyframes[i][e];h=this.getMiddle(q);o=h.x;n=h.y}if(o>0.5){k=1;d=(o-0.5)/0.5}else{k=0;d=Math.abs(0.5-o)/0.5}if(n!==void 0){if(n>0.5){j=3;c=(n-0.5)/0.5}else{j=2;c=Math.abs(0.5-n)/0.5}}if(n===void 0){g.x+=f[k].x*d;g.y-=f[k].y*d}else{g.x+=f[k].x*d;g.y-=f[j].y*c}return g}};b.prototype.getRotate=function(j){var i,h,f,d,c,e,k,l,g;g=this.copy(this.app_json.layer[j].rotate);k=this.app_json.layer[j].parameter;h=this.app_state.keyframes;for(d in k){e=k[d].rotate;if(e===void 0){continue}c=this.app_state.parameter[d].x;if(h!==false){l=this.app_json.keyframes[h][d];f=this.getMiddle(l);c=f.x}if(c>0.5){i=1;c=(c-0.5)/0.5}else{i=0;c=Math.abs(0.5-c)/0.5}g+=e[i]*c}return g};b.prototype.getPosition=function(d){var c;c=this.copy(this.app_json.layer[d].init_position);c=this.diffPosition(d,c);c=this.movePosition(d,c);c=this.rotatePosition(d,c);return c};b.prototype.scale=function(c){var g,e,k,l,f,d,h;f=d=0;if(this.app_state.position.x<0.5){f=5*((this.app_state.position.x-0.5)/1)}else{f=5*((this.app_state.position.x-0.5)/1)}if(this.app_state.position.y<0.5){d=5*((0.5-this.app_state.position.y)/1)}else{d=5*(-(this.app_state.position.y-0.5)/1)}k=c.length/3;for(l=e=0,h=k-1;0<=h?e<=h:e>=h;l=0<=h?++e:--e){g=l*3;c[g]+=f;c[g]*=this.app_state.scale;c[g+1]+=d;c[g+1]*=this.app_state.scale}return c};b.prototype.diffPosition=function(D,E){var s,r,C,z,v,q,d,u,t,h,A,w,g,e,B,f,p,c,o,l;e=this.app_json.layer[D].parameter;q=this.app_state.keyframes;for(h in e){g=e[h].position;c=this.app_json.parameter[h].type;o=this.app_state.parameter[h].x;l=this.app_state.parameter[h].y;s=A=0;r=w=0;if(g===void 0){continue}if(q!==false){B=this.app_json.keyframes[q][h];u=this.getMiddle(B,c);o=u.x;l=u.y}if(o>0.5){s=1;A=(o-0.5)/0.5}else{s=0;A=Math.abs(0.5-o)/0.5}if(l!==void 0){if(l>0.5){r=3;w=(l-0.5)/0.5}else{r=2;w=Math.abs(0.5-l)/0.5}}d=g[s].length/3;if(l===void 0){for(t=z=0,f=d-1;0<=f?z<=f:z>=f;t=0<=f?++z:--z){C=t*3;E[C]+=g[s][C]*A;E[C+1]+=g[s][C+1]*A}}else{for(t=v=0,p=d-1;0<=p?v<=p:v>=p;t=0<=p?++v:--v){C=t*3;E[C]+=g[s][C]*A;E[C+1]+=g[r][C+1]*w}}}return E};b.prototype.movePosition=function(g,c){var f,e,k,d,l,h;d=this.getMove(g);k=c.length/3;for(f=e=0,h=k-1;0<=h?e<=h:e>=h;f=0<=h?++e:--e){l=f*3;c[l]+=d.x;c[l+1]-=d.y}return c};b.prototype.rotatePosition=function(p,o){var v,d,m,l,f,h,r,g,e,k,q,u,c,t,s;k=this.getRotate(p);u=this.app_json.layer[p].anchor.x;t=this.app_json.layer[p].anchor.y;f=o.length/3;for(m=l=0,g=f-1;0<=g?l<=g:l>=g;m=0<=g?++l:--l){h=m*3;c=o[h];s=o[h+1];e=Math.atan2(s-t,c-u)*180/Math.PI;d=Math.sqrt((c-u)*(c-u)+(s-t)*(s-t));e+=k;r=e*Math.PI/180;q=Math.sin(r);v=Math.cos(r);o[h]=(v*d)+u;o[h+1]=(q*d)+t}return o};b.prototype.clear=function(){this.gl.clearColor(0,0,0,0);this.gl.clearDepth(1);return this.gl.clear(this.gl.COLOR_BUFFER_BIT|this.gl.DEPTH_BUFFER_BIT)};b.prototype.viewMatrix=function(){this.m.lookAt([0,0,5.35],[0,0,0],[0,1,0],this.v_matrix);this.m.perspective(50,this.width/this.height,0.1,100,this.p_matrix);this.m.multiply(this.p_matrix,this.v_matrix,this.tmp_matrix);return this.m.multiply(this.tmp_matrix,this.m_matrix,this.mvp_matrix)};b.prototype.draw=function(){var e,h,f,l,c,g,d,k,i;this.clear();this.viewMatrix();this.blendType(0);this.gl.enable(this.gl.BLEND);c=this.app_json.layer.length;if(c<=0){return}for(l=f=0,d=c-1;0<=d?f<=d:f>=d;l=0<=d?++f:--f){g=this.getPosition(l);e=this.copy(this.app_json.layer[l].color);i=this.copy(this.app_json.layer[l].texture_coord);h=this.copy(this.app_json.layer[l].index);k=this.app_json.layer[l].show;g=this.scale(g);if(!g){continue}if(k==="hidden"){continue}this.vPosition=this.createVbo(g);this.vColor=this.createVbo(e);this.vTextureCoord=this.createVbo(i);this.iIndex=this.createIbo(h);this.setAttribute(this.vPosition,this.attLocation.position,this.attStride.position);this.setAttribute(this.vColor,this.attLocation.color,this.attStride.color);this.setAttribute(this.vTextureCoord,this.attLocation.texture,this.attStride.texture);this.gl.bindTexture(this.gl.TEXTURE_2D,this.texture[this.app_json.layer[l].name]);this.gl.uniformMatrix4fv(this.uniLocation.mvpMatrix,false,this.mvp_matrix);this.gl.uniform1i(this.uniLocation.texture,0);this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER,this.iIndex);this.gl.drawElements(this.gl.TRIANGLES,this.app_json.layer[l].index.length,this.gl.UNSIGNED_SHORT,0)}return this.gl.flush()};b.prototype.loop=function(){var c;c=1000/30;return this.timer=setInterval((function(d){return function(){var e;if(d.app_state.keyframes!==false){if(d.app_state.time>d.max){e=d.app_state.keyframes;d.app_state.keyframes=false;d.app_state.time=0;d.emit("end",e);return}d.app_state.time+=2}return d.draw()}})(this),c)};b.prototype.getParamList=function(){var c;c=this.app_json.parameter;return this.copy(c)};b.prototype.getParamStateList=function(){var c;c=this.app_state.parameter;return this.copy(c)};b.prototype.getParam=function(d){var c,e,f;f=this.app_json.parameter;for(c in f){e=f[c];if(d===c){return this.copy(e)}}return false};b.prototype.getParamState=function(d){var c,e,f;f=this.app_state.parameter;for(c in f){e=f[c];if(d===c){return this.copy(e)}}return false};b.prototype.setParam=function(d,f){var g,c,e;g=this.app_json.parameter[d];if(g===void 0){return false}c={};e=g.type;if(e===4){c={x:f.x,y:f.y}}else{c={x:f.x}}this.app_state.parameter[d]=c;this.emit("change",{name:g,val:c});return true};b.prototype.animate=function(c){this.app_state.time=0;this.app_state.keyframes=c;this.max=this.getDuration(c);return this.emit("start",this.app_state.keyframes)};b.prototype.getDuration=function(f){var e,c,d,g;c=0;for(d in this.app_json.keyframes[f]){g=this.app_json.keyframes[f][d];e=g[g.length-1].time;if(c<e){c=e}}return c};b.prototype.getLayerList=function(){var c;c=this.copy(this.app_json.layer);return c};b.prototype.getLayer=function(g){var d,f,c,h,e;h=this.copy(this.app_json.layer);for(f=0,e=h.length;f<e;f++){c=h[f];d=c.name;if(g===d){return c}}};b.prototype.show=function(g){var d,f,c,i,e,h;i=this.app_json.layer;h=[];for(f=0,e=i.length;f<e;f++){c=i[f];d=c.name;if(g===d){h.push(c.show="show")}else{h.push(void 0)}}return h};b.prototype.hidden=function(g){var d,f,c,i,e,h;i=this.app_json.layer;h=[];for(f=0,e=i.length;f<e;f++){c=i[f];d=c.name;if(g===d){h.push(c.show="hidden")}else{h.push(void 0)}}return h};function a(){this.create=function(){return new Float32Array(16)};this.identity=function(c){c[0]=1;c[1]=0;c[2]=0;c[3]=0;c[4]=0;c[5]=1;c[6]=0;c[7]=0;c[8]=0;c[9]=0;c[10]=1;c[11]=0;c[12]=0;c[13]=0;c[14]=0;c[15]=1;return c};this.multiply=function(B,D,l){var G=B[0],H=B[1],I=B[2],J=B[3],K=B[4],L=B[5],M=B[6],N=B[7],O=B[8],P=B[9],af=B[10],ag=B[11],ah=B[12],ai=B[13],aj=B[14],c=B[15],d=D[0],e=D[1],f=D[2],g=D[3],h=D[4],i=D[5],j=D[6],k=D[7],m=D[8],n=D[9],o=D[10],p=D[11],A=D[12],C=D[13],E=D[14],F=D[15];l[0]=d*G+e*K+f*O+g*ah;l[1]=d*H+e*L+f*P+g*ai;l[2]=d*I+e*M+f*af+g*aj;l[3]=d*J+e*N+f*ag+g*c;l[4]=h*G+i*K+j*O+k*ah;l[5]=h*H+i*L+j*P+k*ai;l[6]=h*I+i*M+j*af+k*aj;l[7]=h*J+i*N+j*ag+k*c;l[8]=m*G+n*K+o*O+p*ah;l[9]=m*H+n*L+o*P+p*ai;l[10]=m*I+n*M+o*af+p*aj;l[11]=m*J+n*N+o*ag+p*c;l[12]=A*G+C*K+E*O+F*ah;l[13]=A*H+C*L+E*P+F*ai;l[14]=A*I+C*M+E*af+F*aj;l[15]=A*J+C*N+E*ag+F*c;return l};this.scale=function(f,d,e){e[0]=f[0]*d[0];e[1]=f[1]*d[0];e[2]=f[2]*d[0];e[3]=f[3]*d[0];e[4]=f[4]*d[1];e[5]=f[5]*d[1];e[6]=f[6]*d[1];e[7]=f[7]*d[1];e[8]=f[8]*d[2];e[9]=f[9]*d[2];e[10]=f[10]*d[2];e[11]=f[11]*d[2];e[12]=f[12];e[13]=f[13];e[14]=f[14];e[15]=f[15];return e};this.translate=function(f,d,e){e[0]=f[0];e[1]=f[1];e[2]=f[2];e[3]=f[3];e[4]=f[4];e[5]=f[5];e[6]=f[6];e[7]=f[7];e[8]=f[8];e[9]=f[9];e[10]=f[10];e[11]=f[11];e[12]=f[0]*d[0]+f[4]*d[1]+f[8]*d[2]+f[12];e[13]=f[1]*d[0]+f[5]*d[1]+f[9]*d[2]+f[13];e[14]=f[2]*d[0]+f[6]*d[1]+f[10]*d[2]+f[14];e[15]=f[3]*d[0]+f[7]*d[1]+f[11]*d[2]+f[15];return e};this.rotate=function(am,an,A,w){var g=Math.sqrt(A[0]*A[0]+A[1]*A[1]+A[2]*A[2]);if(!g){return null}var ah=A[0],ai=A[1],aj=A[2];if(g!=1){g=1/g;ah*=g;ai*=g;aj*=g}var ak=Math.sin(an),al=Math.cos(an),c=1-al,d=am[0],e=am[1],f=am[2],h=am[3],i=am[4],j=am[5],k=am[6],l=am[7],m=am[8],n=am[9],p=am[10],q=am[11],r=ah*ah*c+al,s=ai*ah*c+aj*ak,t=aj*ah*c-ai*ak,u=ah*ai*c-aj*ak,v=ai*ai*c+al,x=aj*ai*c+ah*ak,y=ah*aj*c+ai*ak,z=ai*aj*c-ah*ak,o=aj*aj*c+al;if(an){if(am!=w){w[12]=am[12];w[13]=am[13];w[14]=am[14];w[15]=am[15]}}else{w=am}w[0]=d*r+i*s+m*t;w[1]=e*r+j*s+n*t;w[2]=f*r+k*s+p*t;w[3]=h*r+l*s+q*t;w[4]=d*u+i*v+m*x;w[5]=e*u+j*v+n*x;w[6]=f*u+k*v+p*x;w[7]=h*u+l*v+q*x;w[8]=d*y+i*z+m*o;w[9]=e*y+j*z+n*o;w[10]=f*y+k*z+p*o;w[11]=h*y+l*z+q*o;return w};this.lookAt=function(B,A,L,M){var H=B[0],J=B[1],N=B[2],l=L[0],y=L[1],z=L[2],O=A[0],P=A[1],Q=A[2];if(H==O&&J==P&&N==Q){return this.identity(M)}var C,D,E,R,S,T,G,I,K,F;G=H-A[0];I=J-A[1];K=N-A[2];F=1/Math.sqrt(G*G+I*I+K*K);G*=F;I*=F;K*=F;C=y*K-z*I;D=z*G-l*K;E=l*I-y*G;F=Math.sqrt(C*C+D*D+E*E);if(!F){C=0;D=0;E=0}else{F=1/F;C*=F;D*=F;E*=F}R=I*E-K*D;S=K*C-G*E;T=G*D-I*C;F=Math.sqrt(R*R+S*S+T*T);if(!F){R=0;S=0;T=0}else{F=1/F;R*=F;S*=F;T*=F}M[0]=C;M[1]=R;M[2]=G;M[3]=0;M[4]=D;M[5]=S;M[6]=I;M[7]=0;M[8]=E;M[9]=T;M[10]=K;M[11]=0;M[12]=-(C*H+D*J+E*N);M[13]=-(R*H+S*J+T*N);M[14]=-(G*H+I*J+K*N);M[15]=1;return M};this.perspective=function(t,u,r,s,n){var c=r*Math.tan(t*Math.PI/360);var v=c*u;var o=v*2,p=c*2,q=s-r;n[0]=r*2/o;n[1]=0;n[2]=0;n[3]=0;n[4]=0;n[5]=r*2/p;n[6]=0;n[7]=0;n[8]=0;n[9]=0;n[10]=-(s+r)/q;n[11]=-1;n[12]=0;n[13]=0;n[14]=-(s*r*2)/q;n[15]=0;return n};this.transpose=function(c,d){d[0]=c[0];d[1]=c[4];d[2]=c[8];d[3]=c[12];d[4]=c[1];d[5]=c[5];d[6]=c[9];d[7]=c[13];d[8]=c[2];d[9]=c[6];d[10]=c[10];d[11]=c[14];d[12]=c[3];d[13]=c[7];d[14]=c[11];d[15]=c[15];return d};this.inverse=function(ai,v){var A=ai[0],B=ai[1],af=ai[2],ag=ai[3],ah=ai[4],aj=ai[5],c=ai[6],d=ai[7],e=ai[8],f=ai[9],g=ai[10],h=ai[11],i=ai[12],j=ai[13],k=ai[14],l=ai[15],n=A*aj-B*ah,p=A*c-af*ah,q=A*d-ag*ah,r=B*c-af*aj,s=B*d-ag*aj,t=af*d-ag*c,u=e*j-f*i,w=e*k-g*i,x=e*l-h*i,y=f*k-g*j,m=f*l-h*j,o=g*l-h*k,z=1/(n*o-p*m+q*y+r*x-s*w+t*u);v[0]=(aj*o-c*m+d*y)*z;v[1]=(-B*o+af*m-ag*y)*z;v[2]=(j*t-k*s+l*r)*z;v[3]=(-f*t+g*s-h*r)*z;v[4]=(-ah*o+c*x-d*w)*z;v[5]=(A*o-af*x+ag*w)*z;v[6]=(-i*t+k*q-l*p)*z;v[7]=(e*t-g*q+h*p)*z;v[8]=(ah*m-aj*x+d*u)*z;v[9]=(-A*m+B*x-ag*u)*z;v[10]=(i*s-j*q+l*n)*z;v[11]=(-e*s+f*q-h*n)*z;v[12]=(-ah*y+aj*w-c*u)*z;v[13]=(A*y-B*w+af*u)*z;v[14]=(-i*r+j*p-k*n)*z;v[15]=(e*r-f*p+g*n)*z;return v}}return b})()}).call(this);