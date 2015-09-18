# trajectory 
- keyframe.m: get key frame and save.
- linecrosspoint.m: get cross point,called by trajectorysimilar.m 
- trajectorysimilar.m: find similarity relationship between trajectory.
- trajectorynorm.m: resample points and norm it to [0,1] by [width height].
- trajectorycross.m: find cross relationship between trajectory.

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

##data structure
- feature:
size(feature)= 356 64
- status=1(new), status=2(normal),status=3(lost)
- newcount,lostcount


~~~mermaid
graph TD;

a[newblob]---feature
a---point
a---status
a---newcount
a---lostcount
a---group
a---grouptmp


a---area*
a---center*
a---pixellist*
a---boundary*

a---input+
a---mask+
a---time+

~~~


~~~mermaid
graph TD;

a[oldblob]---feature
a---point
a---status
a---newcount
a---lostcount
a---group
a---grouptmp

a---input+
a---mask+
a---time+

~~~

##update paired feature
- pair 
size(pair)= featurenum 2
pair=[newfeatureid,oldfeatureid]
- mingrouptmpid
mingrouptmpid=grouptmpid

```
for j=1:newblobnum	(newblobnum=length(newblob.area) )
	newblob.grouptmp(i)=j+grouptmpid
end
grouptmpid=grouptmpid+nweblobnum
```

**grouptmpid match to newblobid, sudo we use it to group**

- time

** we use time to distingush matched old feature and unmatched **


##blob analyze function
- track_yzbx.blobMatch

newblobpair(newblob_id,pair_id)=true|false

```
oldblob.feature(i)=newblob.feature(j)
```

~~~mermaid
graph TD;
	a[pair]-->b[newmatch];
	newblob-->a
	oldblob-->a
	b-->newlocation;
	newlocation-->newgroup[newblobgroup]
	p[newblob.pixellist]-->newgroup;
	a-->d[oldblob update];
	
~~~


~~~mermaid
graph TD;
	newblobgroup-->boundary
	boundary-->a[oldblobgroup update]
	oldblobgroup-->maxdistance
	maxdistance-->a
~~~
- blobSizeAndCenter()
- blobSpeed()
- blobFeature()

##object track funtion

- statusUpdate()


