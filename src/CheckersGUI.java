import javax.swing.*; //move to javaFX
import java.awt.*;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class CheckersGUI {

    private JFrame frame;
    private JPanel panel;
    private JPanel boardPanel;
    private JLabel title;
    private JButton[][] buttons;


    public CheckersGUI(){
        frame = new JFrame();
        panel = new JPanel();
        boardPanel = new JPanel();
        title = new JLabel("Checkers Game - Prolog", SwingConstants.CENTER);
        buttons = new JButton[8][8];

        title.setFont(title.getFont().deriveFont(35.0f));

        panel.setBorder(BorderFactory.createEmptyBorder(15,40,80,40));
        panel.setLayout(new GridLayout(2,0));
        boardPanel.setLayout(new GridLayout(8,8));
        panel.add(title);
        panel.add(boardPanel);

        int tag=1;
        for(int i = 0; i < 8; i++) {
            for (int j = 0; j < 8; j++) {
                int x = tag%2;
                buttons[i][j] = new JButton(" ");
                if(x==0){

                    buttons[i][j].setBackground(Color.black);
                    buttons[i][j].setForeground(Color.white);
                }else {
                    buttons[i][j].setBackground(Color.white);
                }
                tag++;
                boardPanel.add(buttons[i][j]);
            }
            tag++;

        }


        frame.add(panel, BorderLayout.CENTER);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setTitle("Checkers Game");
        frame.pack();
        frame.setVisible(true);

    }

    public static  void main(String[] args) throws IOException {
        new CheckersGUI();
        ProcessBuilder builder = new ProcessBuilder("swipl","checkers.pl");
        builder.redirectErrorStream(true); // so we can ignore the error stream
        Process process = builder.start();
        InputStream out = process.getInputStream();
        OutputStream in = process.getOutputStream();

        byte[] buffer = new byte[4000];
        while (isAlive(process)) {
            int no = out.available();
            if (no > 0) {
                int n = out.read(buffer, 0, Math.min(no, buffer.length));
                System.out.println(new String(buffer, 0, n));
            }

            int ni = System.in.available();
            if (ni > 0) {
                int n = System.in.read(buffer, 0, Math.min(ni, buffer.length));
                in.write(buffer, 0, n);
                in.flush();
            }

            try {
                Thread.sleep(10);
            }
            catch (InterruptedException e) {
            }
        }

        System.out.println(process.exitValue());


    }

    public static boolean isAlive(Process p) {
        try {
            p.exitValue();
            return false;
        }
        catch (IllegalThreadStateException e) {
            return true;
        }
    }

}
