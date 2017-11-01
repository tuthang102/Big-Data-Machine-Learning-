% subplot(3,1,1)
% h1=histogram(trainEr,edges,'FaceAlpha',1,'FaceColor','b');
% title('Error Histogram')
% legend('Training')
% xlim([-400 400])
% set(gca,'FontSize',18)
% % ylim([0 0.2])
% 
% subplot(3,1,2)
% h2=histogram(valEr,edges,'FaceAlpha',1,'FaceColor','g');
% ylabel('Normalized Probability')
% set(gca,'FontSize',18)
% legend('Validation')
% xlim([-400 400])
% % ylim([0 0.2])
% 
% subplot(3,1,3)
% h3=histogram(testEr,edges,'FaceAlpha',1,'FaceColor','r');
% set(gca,'FontSize',18)
% legend('Testing')
% xlim([-400 400])
% h1.Normalization='probability';
% h2.Normalization='probability';
% h3.Normalization='probability';
% xlabel('Errors')
% % ylim([0 0.2])