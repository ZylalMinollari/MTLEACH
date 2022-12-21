
clear;
%%%%%%MTLEACH%%%%%%%%
xm=300;      
ym=300;

sink.x=100;  
sink.y=75;

n = 200;         

p=0.1;          

Eo=0.5;         
ch=n/10;
ETX=50*0.000000001;     
ERX=50*0.000000001;        

Efs=10*0.000000000001;     
Emp=0.0013*0.000000000001;      
Efs1=Efs/10;   
Emp1=Emp/10;
%Data Aggregation Energy
EDA=5*0.000000001;

a=Eo/2;               

rmax=1000;           
%temprature range
tempi=50;
tempf=200;

%Thresholod for transmiting data to the cluster head
h=100;                                
s=2;                                   

sv=0;                                  


do=sqrt(Efs/Emp);       
do1=sqrt(Efs1/Emp1);    
for i=1:1:n
   S(i).xd=rand(1,1)*xm;        
   XR(i)=S(i).xd;                  
   S(i).yd=rand(1,1)*ym;           
   YR(i)=S(i).yd;
   S(i).G=0;                        
   S(i).E=Eo;
   S(i).type='N';
end

S(n+1).xd=sink.x;   
S(n+1).yd=sink.y;

countCHs=0;         
cluster=1;              
flag_first_dead=0;         
flag_teenth_dead=0;
flag_all_dead=0;

dead=0;
first_dead=0;
teenth_dead=0;
all_dead=0;

allive=n;
%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;
for r=0:1:rmax
        cv = tempi + (tempf-tempi).*rand(1,1);  
   if(mod(r, round(1/p) )==0) 
   for i=1:1:n
       S(i).G=0;            
   end
   end

dead=0;
for i=1:1:n

   if (S(i).E<=0)
       dead=dead+1;

       if (dead==1)
          if(flag_first_dead==0)
             first_dead=r;
             flag_first_dead=1;
          end
       end

       if(dead==0.1*n)
          if(flag_teenth_dead==0)
             teenth_dead=r;
             flag_teenth_dead=1;
          end
       end
       if(dead==n)
          if(flag_all_dead==0)
             all_dead=r;
             flag_all_dead=1;
          end
       end
   end
   if S(i).E>0
       S(i).type='N';
   end
end
STATISTICS.DEAD(r+1)=dead;
STATISTICS.ALLIVE(r+1)=allive-dead;

countCHs=0;
cluster=1;

if   S(i).type=='C' && S(i).E>a
for j=1:1:ch
    countCHs=countCHs+1;
    S(i).type='C';
           S(i).G=round(1/p)-1;
           C(cluster).xd=S(i).xd;
           C(cluster).yd=S(i).yd;
    distance=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
           C(cluster).distance=distance;
           C(cluster).id=i;
           X(cluster)=S(i).xd;
           Y(cluster)=S(i).yd;
           cluster=cluster+1;
distance;
           
           if (distance>do)
               S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*(distance*distance*distance*distance ));
           end
           if (distance<=do)
               S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*(distance * distance ));
           end
end
else
for i=1:1:n        
  if(S(i).E>0)
  temp_rand=rand;
  if ( (S(i).G)<=0)

       if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
           countCHs=countCHs+1;
           packets_TO_BS=packets_TO_BS+1;
           PACKETS_TO_BS(r+1)=packets_TO_BS;
            S(i).type='C';
           S(i).G=round(1/p)-1;
           C(cluster).xd=S(i).xd;
           C(cluster).yd=S(i).yd;
          distance=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
           C(cluster).distance=distance;
           C(cluster).id=i;
           X(cluster)=S(i).xd;
           Y(cluster)=S(i).yd;
           cluster=cluster+1;       
           distance;
           if (distance>do)
               S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*(distance*distance*distance*distance ));
           end
           if (distance<=do)
               S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*(distance * distance ));
           end
       end
  end

  end
end
end
STATISTICS.COUNTCHS(r+1)=countCHs;

for i=1:1:n
  if ( S(i).type=='N' && S(i).E>0 )
    if(cluster-1>=1)
      min_dis=Inf;
      min_dis_cluster=0;
      for c=1:1:cluster-1
          temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
          if ( temp<min_dis )
              min_dis=temp;
              min_dis_cluster=c;
          end
      end
           min_dis;
           if (min_dis>do1)
               S(i).E=S(i).E- ( ETX*(4000) + Emp1*4000*( min_dis *min_dis * min_dis * min_dis));
           end
          if (min_dis<=do1)
               S(i).E=S(i).E- ( ETX*(4000) + Efs1*4000*( min_dis * min_dis));
           end
                  S(C(min_dis_cluster).id).E =S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 );
           packets_TO_CH=packets_TO_CH+1;
        
       S(i).min_dis=min_dis;
       S(i).min_dis_cluster=min_dis_cluster;
   else
       min_dis=sqrt( (S(i).xd-S(n+1).xd)^2 + (S(i).yd-S(n+1).yd)^2 );
           if (min_dis>do)
               S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis *min_dis * min_dis * min_dis));
           end
           if (min_dis<=do)
               S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis));
           end
           packets_TO_BS=packets_TO_BS+1;
    
  sv=cv;
    end
 end
end
STATISTICS.PACKETS_TO_CH(r+1)=packets_TO_CH;
STATISTICS.PACKETS_TO_BS(r+1)=packets_TO_BS;

end
first_dead;
teenth_dead;
all_dead;
STATISTICS.DEAD(r+1)
STATISTICS.ALLIVE(r+1)
STATISTICS.PACKETS_TO_CH(r+1)
STATISTICS.PACKETS_TO_BS(r+1)
STATISTICS.COUNTCHS(r+1)

r=0:rmax;
figure (1);
plot(r,STATISTICS.DEAD);
xlabel('Rounds');
ylabel('Dead Nodes');
title('MTLEACH');
figure (2);
plot(r,STATISTICS.PACKETS_TO_BS);
xlabel('Rounds');
ylabel('Packets to BS');
title('MTLEACH');
figure (3);
plot(r,STATISTICS.PACKETS_TO_CH);
xlabel('Rounds');
ylabel('Packets to CH')
title('MTLEACH');
figure (4);
plot(r,STATISTICS.COUNTCHS);
xlabel('Rounds');
ylabel('Number of Cluster Heads');
title('MTLEACH');
