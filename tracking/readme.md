# track

reference: [Urban tracker](http://blog.csdn.net/u010598445/article/details/46628991)

#code frame
##main frame

~~~mermaid
graph LR;
	m[foreground mask] -->a[blob analysis];
	n[frame input]-->a;
	a-->b[object track];
	
~~~
##blob analyze

~~~mermaid
graph TD;
	a[blob analysis]---b[blob size];
	a---c[blob center];
	a---d[blob speed];
	a---e[blob feature];
~~~
##object track status
~~~mermaid
graph TD;
	a[object track status]---b[normal];
	a---c[merged];
	a---d[split];
	a---e[lost];
	a---f[noisy-normal];
	a---g[merged-split];
~~~

##blob analyze function
- track_yzbx.blobMatch
newblobpair(newblobid,pairid)=true|false

~~~mermaid
graph TD;
	a[pair]-->b[newmatch];
	b-->newloc[newlocation]
	p[newblob.pixellist]-->d[newblobpair];
	newloc-->d[newblobpair];
	
~~~
featureMatchNum=sum(newblobpair(newblobid,:)&oldblobpair(oldblobid,:))
matchmat[newblobid][oldblobid]=featureMatchNum

~~~mermaid
graph TD;
	newblobpair-->a[matchmat]
	oldblobpair-->a[matchmat]
~~~
- blobSizeAndCenter()
- blobSpeed()
- blobFeature()

##object track funtion

- statusUpdate()


