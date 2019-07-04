function ParseArrows(arr, matrixRow, matrixCol,start,goal)

CreateGrid(matrixRow, matrixCol,start,goal)

for row = 1:matrixRow
    for col = 1:matrixCol
        for act = 1:size(arr,3)
            if (arr(row,col,act) == 1)
                DrawArrow(act, row, col, matrixRow, matrixCol)
            end
        end
    end
end

function DrawArrow(act, row, col, matrixRow, matrixCol)
rotation = 0;
textToDraw = 'o';

switch act 
   case 1 % east
       textToDraw = '��';
       rotation = 0;
   case 2 % south
       textToDraw = '��';
       rotation = 0;
   case 3 % west
       textToDraw = '��';
       rotation = 0;
   case 4 % north
       textToDraw = '��';
       rotation = 0;
   case 5 % east+ 
       textToDraw = '��';
       rotation = 0;
   case 6 % south+ (Hold)
       textToDraw = 'o';
       rotation = 0;
   case 7 % west+          
       textToDraw = '��';    
       rotation = 0;       
   case 8 % north+
       textToDraw = '���';
       rotation = 0;
   case 9 % east++
       textToDraw = '�֡�';
       rotation = 0;
   case 10 % south++
       textToDraw = '��';
       rotation = 0;
   case 11 % west++
       textToDraw = '���';
       rotation = 0;
   case 12 % north++
       textToDraw = '����';
       rotation = 0;       
   case 13 % 
       textToDraw = '��';   % �����֢עآ�
       rotation = 0;      
   case 14 % 
       textToDraw = '��'; 
       rotation = 0;      
   case 15 % 
       textToDraw = '��';   
       rotation = 0;      
   case 16 % 
       textToDraw = '��';  
       rotation = 0;     
   case 17 % 
       textToDraw = 'o��';  
       rotation = 0;    
   case 18 % 
       textToDraw = '��o'; 
       rotation = 0;    
   case 19 % 
       textToDraw = '�֡�'; 
       rotation = 0;    
   case 20 % 
       textToDraw = '���';
       rotation = 0;    
   case 21 % 
       textToDraw = '��';
       rotation = 0;    
   case 22 % 
       textToDraw = '��';
       rotation = 0;    
   case 23 % 
       textToDraw = '��آ�';
       rotation = 0;        
   case 24 % 
       textToDraw = '�֢֡�';
       rotation = 0;    
       
   otherwise
      disp(sprintf('invalid action index: %d', act))
end

xsp = 1 / (matrixCol + 2);
ysp = 1 / (matrixRow + 2);
xcor = ((2*col + 1) / 2) * xsp;
ycor = 1 - (((2*row + 1) / 2) * ysp);
xcor = xcor - xsp/5;
text(xcor, ycor, textToDraw, 'Rotation', rotation,'fontsize',12)
