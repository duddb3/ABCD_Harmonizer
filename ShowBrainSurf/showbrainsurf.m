function [LL,LM,RL,RM,S,I] = showbrainsurf(cdata,drange,surftype)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% showbrainsurf, version 1.1.0
%
% Software provided with no warranty or guarantee
%
% Created by: Jon Dudley (jonathan.dudley@cchmc.org)
% Last modified: 2022-04-25
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%
% Function to quickly render values (stats, cortical thickness, etc.) onto brain
% surfaces, or to show atlas defined ROIs on the brain surface
%
% Usage:
%   >> showbrainsurf;
%       Allows user to select any subset of ROIs from one of five atlases for
%       display. Two popup menus will appear, the first allowing selection of
%       the atlas (see below) and the second allowing for the selection of any
%       number of ROIs defined by that atlas. Each selected ROI will be
%       displayed in a unique color selected from a set of maximally
%       distinguishable colors based on the number of ROIs selected.
%   >> [LL,LM,RL,RM,S,I] = showbrainsurf;
%       Same as above, but also returns the six thumbnails corresponding to the
%       left lateral, left medial, right lateral, right medial, superior, and
%       inferior views of the brain surface, respectively.
%   >> showbrainsurf(X);
%       Where X is a n-by-1 or n-by-3 vector where each row corresponds to the
%       coordinate or ROI defined by a given template/atlas. If X is n-by-1 (eg,
%       cortical thickness in mm or a z-stat) it will map the values to a
%       colormap based on the values of X (if min(X)>=0, it will map min(X) to
%       max(X) on the colormap hot; if max(X)<=0, it will map min(X) to max(X)
%       on a black-blue-white colormap; otherwise it will map -max(abs(X)) to
%       max(abs(X)) on a blue-white-red colormap. If X is n-by-3, each row is
%       taken to be an RGB color for mapping. The length of n can be:
%           64984, where each row corresponds to a coordinate of the FSaverage
%           template with ~2mm spacing (i.e., ~32k/hemisphere)
%
%           327684, where each row corresponds to a coordinate of the FSaverage
%           template with ~1mm spacing (i.e., ~164k/hemisphere)
%
%           148, where each row corresponds to an ROI in the Destrieux atlas
%
%           70, where each row corresponds to an ROI in the Desikan-Killiany
%           atlas
%
%           360, where each row corresponds to an ROI in the Human Connectome
%           Project MultiModalParcellation atlas
%
%           333, where each row corresponds to an ROI in the Gordon functional
%           parcellation atlas
%
%           100, 200, 400, or 600, where each row corresponds to an ROI in the
%           Schaefer functional parcellation atlas of the given resolution
%
%   >> showbrainsurf(X,[min max]);
%       Same as above, but first thresholds X between min and max
%
%   >> showbrainsurf(X,[min max],mesh);
%       Same as above, but renders explicitly on the mesh indictated by "mesh".
%       Options are 'inflated', 'centralFS', and 'centralT1'
%
%
%   Version history
%
%   1.0.0: initial release
%   1.1.0: added functionality to render on different meshes
%
%
%   This function utilizes the following 
%
%   read_annotation.m: Copyright © 2011 The General Hospital Corporation (Boston, MA) "MGH"
%       Function from FreeSurfer
%
%   @gifti, @xmltree: Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
%       These are classes defined in SPM for reading *.gii files   
%
%   distinguishable_colors.m: 2010-2011 by Timothy E. Holy
%       https://www.mathworks.com/matlabcentral/fileexchange/29702-generate-maximally-perceptually-distinct-colorsCopyright 
%
    pth = fileparts(which('showbrainsurf'));
    addpath(fullfile(pth,'subfunctions'));
    if ~exist('cdata','var')
        pickrois = true;
        atlases = {'Gordon','Destrieux','DK40','HCP_MMP','Schaefer'};
        [sel,ok] = listdlg('ListString',atlases,'SelectionMode','single','PromptString','Which atlas do you want to view?');
        if ~ok
            return
        end
        switch atlases{sel}
            case 'Gordon'
                cdata = 0.5*ones(333,3);
            case 'Destrieux'
                cdata = 0.5*ones(148,3);
            case 'DK40'
                cdata = 0.5*ones(70,3);
            case 'HCP_MMP'
                cdata = 0.5*ones(360,3);
            case 'Schaefer'
                cdata = 0.5*ones(600,3);
        end
    else
        pickrois = false;
    end
    if exist('surftype','var')
        switch surftype
            case 'inflated'
                surfname = 'inflated.freesurfer.gii';
            case 'centralFS'
                surfname = 'central.freesurfer.gii';
            case 'centralT1'
                surfname = 'central.Template_T1.gii';
            otherwise
                fprintf(2,sprintf('Surface name not recognized. Third input must be one of: ''%s'', ''%s'', or ''%s''\n','inflated','centralFS','centralT1'));
        end
    else
        surfname = 'inflated.freesurfer.gii';
    end
    if size(cdata,2)==1
        if exist('drange','var')
            if isempty(drange)
                mn = min(cdata);
                mx = max(cdata);
            else
                mn = drange(1);
                mx = drange(2);
            end
        else
            mn = min(cdata);
            mx = max(cdata);
        end
        
        if mn>=0
            numcol = min(256,length(unique(cdata)));
            figure('Visible','off')
            cmap = colormap(hot(numcol));
            close(gcf)
        elseif mx<=0
            numcol = min(256,length(unique(cdata)));
            figure('Visible','off')
            cmap = flip(flip(colormap(hot(numcol)),1),2);
            close(gcf)
        else
            numcol = 256;
            if nargin==1
                cb = max(abs(cdata));
                mn = -cb;
                mx = cb;
            end
            cmap = ones(256,3);
            cmap(1:128,1:2) = repmat(linspace(0,1,128)',1,2);
            cmap(129:256,2:3) = repmat(linspace(1,0,128)',1,2);
            cmap = cmap.^0.75;
        end
        inan = isnan(cdata);
        cdata = gray2ind(mat2gray(cdata,[mn mx]),numcol);
        cdata = squeeze(ind2rgb(cdata,cmap));
        cdata(repmat(inan,1,3)) = repmat([.5 .5 .5],sum(inan),1);
        pcb = true;
    else
        pcb = false;
    end

    switch size(cdata,1)
        case 64984 % vertex-level data at 32k/hemisphere (~2mm spacing)
            tdir = fullfile(pth,'templates','templates_surfaces_32k');
            L = gifti(fullfile(tdir,['lh.' surfname]));
            R = gifti(fullfile(tdir,['rh.' surfname]));
            ldata = cdata(1:length(L.vertices),:);
            rdata = cdata(length(L.vertices)+1:end,:);
        case 327684 % vertex-level data at ~1mm spacing
            tdir = fullfile(pth,'templates','templates_surfaces');
            L = gifti(fullfile(tdir,['lh.' surfname]));
            R = gifti(fullfile(tdir,['rh.' surfname]));
            ldata = cdata(1:length(L.vertices),:);
            rdata = cdata(length(L.vertices)+1:end,:);
        case 333 % Gordon functional atlas
            tdir = fullfile(pth,'templates','templates_surfaces_32k');
            L = gifti(fullfile(tdir,['lh.' surfname]));
            R = gifti(fullfile(tdir,['rh.' surfname]));
            gdir = fullfile(pth,'templates','Gordon_atlas');
            GL = gifti(fullfile(gdir,'Parcels_L.func.gii'));
            GR = gifti(fullfile(gdir,'Parcels_R.func.gii'));
            if pickrois
                GAlabels = readtable(fullfile(gdir,'Parcels.xlsx'));
                [~,o] = sort(GAlabels.Community);
                coms = GAlabels.Community(o);
                ids = cellfun(@num2str,num2cell(GAlabels.ParcelID(o)),'Uni',0);
                rois = cellfun(@(x,y) [x '_ParcelID-' y],coms,ids,'Uni',0);
                [sel,ok] = listdlg('ListString',rois,'PromptString','Which ROI(s) to display?',...
                    'ListSize',[600 600]);
                if ~ok
                    return
                end
                cdata(o(sel),:) = distinguishable_colors(length(sel),[.5 .5 .5]);
            end
            ldata = 0.5.*ones(length(L.vertices),size(cdata,2));
            rdata = 0.5.*ones(length(R.vertices),size(cdata,2));
            for n=1:333
                li = GL.cdata==n;
                ldata(li,:) = repmat(cdata(n,:),sum(li),1);
                ri = GR.cdata==n;
                rdata(ri,:) = repmat(cdata(n,:),sum(ri),1);
            end
        otherwise % atlas-defined data
            adir = fullfile(pth,'templates','atlases_surfaces');
            tdir = fullfile(pth,'templates','templates_surfaces');
            L = gifti(fullfile(tdir,['lh.' surfname]));
            R = gifti(fullfile(tdir,['rh.' surfname]));
            switch size(cdata,1)
                case 148 % Destrieux
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_a2009s.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_a2009s.freesurfer.annot'),0);
                    idx = [2:42,44:76]; % skip "unknown" and "medial wall"
                case 68 % DK40, but without corpus callosum listed
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_DK40.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_DK40.freesurfer.annot'),0);
                    idx = [2:36]; % skip "unknown"
                    % Insert null data for corpus callosum
                    cdata = [cdata(1:3,:); repmat(NaN,1,size(cdata,2));...
                        cdata(4:37,:); repmat(NaN,1,size(cdata,2)); cdata(38:end,:)];
                case 70 % DK40
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_DK40.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_DK40.freesurfer.annot'),0);
                    idx = 2:36; % skip "unknown"
                case 360 % HCP multimodal
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_HCP_MMP1.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_HCP_MMP1.freesurfer.annot'),0);
                    idx = 2:181; % skip "???"
                case {100,200,400,600} % Schaefer2018_XXXParcels_17Networks
                    [~,llab,lctab] = read_annotation(fullfile(adir,sprintf('lh.Schaefer2018_%iParcels_17Networks_order.annot',size(cdata,1))),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,sprintf('rh.Schaefer2018_%iParcels_17Networks_order.annot',size(cdata,1))),0);
                    idx = 2:length(lctab.struct_names); % skip "???"                    

                otherwise
                    fprintf(2,'Size of cdata not compatible\n')
                    return
            end
            if pickrois
                [sel,ok] = listdlg('ListString',[lctab.struct_names(idx);rctab.struct_names(idx)],'PromptString','Which ROI(s) to display?',...
                    'ListSize',[600 600]);
                if ~ok
                    return
                end
                cdata(sel,:) = distinguishable_colors(length(sel),[.5 .5 .5]);
            end
            ldata = 0.5.*ones(length(llab),size(cdata,2));
            rdata = 0.5.*ones(length(rlab),size(cdata,2));
            for n=1:size(cdata,1)/2
                li = llab==lctab.table(idx(n),5);
                ldata(li,:) = repmat(cdata(n,:),sum(li),1);
            end
            for n=1:size(cdata,1)/2
                ri = rlab==rctab.table(idx(n),5);
                rdata(ri,:) = repmat(cdata(n+length(idx),:),sum(ri),1);
            end
    end

    
    figure,
    set(gcf,'Color','w','Position',[100 100 300 250])
    p1 = patch('Faces',L.faces,'Vertices',L.vertices);
    p1.AmbientStrength = 0.6;
    p1.SpecularStrength = 0.1;
    p1.SpecularExponent = 100;
    p1.FaceLighting = 'gouraud';
    p1.EdgeColor = 'none';
    p1.FaceVertexCData = ldata;
    p1.FaceColor = 'interp';
    
    p2 = patch('Faces',R.faces,'Vertices',R.vertices);
    p2.AmbientStrength = 0.6;
    p2.SpecularStrength = 0.1;
    p2.SpecularExponent = 100;
    p2.FaceLighting = 'gouraud';
    p2.EdgeColor = 'none';
    p2.FaceVertexCData = rdata;
    p2.FaceColor = 'interp';
    p2.Visible = 'off';
    
    axis equal vis3d off
    
    % Left lateral view
    view(-90,0);
    l1 = lightangle(-90,0);
    l1.Color = [255 225 195]./255;
    LL = frame2im(getframe(gcf));
    % Left medial view
    view(90,0);
    l1.Position = [sqrt(2) 0 0];
    LM = frame2im(getframe(gcf));
    
    % Right lateral view
    p2.Visible = 'on';
    p1.Visible = 'off';
    RL = frame2im(getframe(gcf));
    % Right medial view
    view(-90,0);
    l1.Position = [-sqrt(2) 0 0];
    RM = frame2im(getframe(gcf));
    
    % Superior view
    p1.Visible = 'on';
    view(0,90);
    l1.Position = [0 0 sqrt(2)];
    S = frame2im(getframe(gcf));
    % Inferior view
    view(-180,-90);
    l1.Position = [0 0 -sqrt(2)];
    I = frame2im(getframe(gcf));
    
    close(gcf)
    
    figure,imshow([LL S RL; LM I RM]);
    set(gcf,'Color','w')
    if pcb
        colormap(cmap)
        p = colorbar;
        p.Ticks = [0 1];
        p.TickLabels = strsplit(num2str([mn,mx]));
    end
end