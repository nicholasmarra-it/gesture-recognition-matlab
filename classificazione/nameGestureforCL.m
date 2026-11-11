function [nomeGesto] = nameGestureforCL(index)
% Restituisce il nome del gesto in base al suo indice

gesti = ["GO", "COME", "TURN LEFT", "TURN RIGHT"];

nomeGesto = gesti(index+1);
    
end

