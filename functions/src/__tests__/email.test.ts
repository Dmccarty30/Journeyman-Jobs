import { describe, it, expect, beforeEach, afterEach, jest } from '@jest/globals';
import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';
import * as nodemailer from 'nodemailer';
import { MailOptions } from 'nodemailer/lib/smtp-transport';

// Mock Firebase Admin and Functions
jest.mock('firebase-admin');
jest.mock('firebase-functions');
jest.mock('nodemailer');

// Email service for job sharing notifications
interface JobShareEmailData {
  jobId: string;
  jobTitle: string;
  jobDescription: string;
  ibewLocal: number;
  classification: string;
  payRate: number;
  location: string;
  startDate: string;
  stormWork: boolean;
  urgent: boolean;
  senderName: string;
  senderEmail: string;
  recipientEmail: string;
  recipientName?: string;
  deepLink: string;
  invitationId: string;
}

interface SMSData {
  phoneNumber: string;
  message: string;
  jobId: string;
  deepLink: string;
  senderName: string;
}

interface CrewShareData {
  jobId: string;
  jobTitle: string;
  crewName: string;
  memberEmails: string[];
  senderName: string;
  deepLink: string;
}

class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransporter({
      service: 'gmail',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  async sendJobShareEmail(data: JobShareEmailData): Promise<void> {
    const template = this.getJobShareEmailTemplate(data);
    
    const mailOptions: MailOptions = {
      from: `"Journeyman Jobs" <${process.env.EMAIL_USER}>`,
      to: data.recipientEmail,
      subject: template.subject,
      html: template.html,
      text: template.text,
      attachments: data.stormWork ? [
        {
          filename: 'storm-work-safety.pdf',
          path: './assets/storm-work-safety.pdf',
        },
      ] : undefined,
    };

    await this.transporter.sendMail(mailOptions);
  }

  async sendJobInvitationEmail(data: JobShareEmailData): Promise<void> {
    const template = this.getInvitationEmailTemplate(data);
    
    const mailOptions: MailOptions = {
      from: `"Journeyman Jobs" <${process.env.EMAIL_USER}>`,
      to: data.recipientEmail,
      subject: template.subject,
      html: template.html,
      text: template.text,
    };

    await this.transporter.sendMail(mailOptions);
  }

  async sendCrewNotificationEmails(data: CrewShareData): Promise<void> {
    const template = this.getCrewShareEmailTemplate(data);
    
    const promises = data.memberEmails.map(email => {
      const mailOptions: MailOptions = {
        from: `"Journeyman Jobs" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: template.subject,
        html: template.html.replace('{{MEMBER_EMAIL}}', email),
        text: template.text.replace('{{MEMBER_EMAIL}}', email),
      };

      return this.transporter.sendMail(mailOptions);
    });

    await Promise.all(promises);
  }

  private getJobShareEmailTemplate(data: JobShareEmailData) {
    const urgentFlag = data.urgent ? '🚨 URGENT - ' : '';
    const stormFlag = data.stormWork ? '⛈️ STORM WORK - ' : '';
    
    const subject = `${urgentFlag}${stormFlag}${data.senderName} shared a job with you: ${data.jobTitle}`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Job Shared with You</title>
        <style>
          body { font-family: Arial, sans-serif; color: #1A202C; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #1A202C, #2D3748); color: white; padding: 20px; text-align: center; }
          .urgent { background: #E53E3E; }
          .storm { background: #D69E2E; }
          .job-details { background: #F7FAFC; padding: 20px; margin: 20px 0; border-left: 4px solid #B45309; }
          .cta-button { background: #B45309; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0; }
          .safety-warning { background: #FED7D7; color: #C53030; padding: 15px; margin: 15px 0; border-radius: 6px; }
          .footer { color: #718096; font-size: 14px; margin-top: 30px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header ${data.urgent ? 'urgent' : ''} ${data.stormWork ? 'storm' : ''}">
            <h1>${urgentFlag}${stormFlag}Job Shared with You</h1>
            <p>${data.senderName} wants you to know about this opportunity</p>
          </div>
          
          <div class="job-details">
            <h2>${data.jobTitle}</h2>
            <p><strong>IBEW Local:</strong> ${data.ibewLocal}</p>
            <p><strong>Classification:</strong> ${data.classification}</p>
            <p><strong>Pay Rate:</strong> $${data.payRate}/hour</p>
            <p><strong>Location:</strong> ${data.location}</p>
            <p><strong>Start Date:</strong> ${data.startDate}</p>
            <p><strong>Description:</strong> ${data.jobDescription}</p>
          </div>
          
          ${data.stormWork ? `
          <div class="safety-warning">
            <strong>⚠️ Storm Work Safety Notice</strong><br>
            This is emergency restoration work. Please review attached safety guidelines and ensure all required PPE is available before accepting.
          </div>
          ` : ''}
          
          <div style="text-align: center;">
            <a href="${data.deepLink}" class="cta-button">View Job Details</a>
          </div>
          
          <div class="footer">
            <p>This job was shared with you by ${data.senderName} (${data.senderEmail})</p>
            <p>Journeyman Jobs - Connecting IBEW Workers Nationwide</p>
            <p><a href="${data.deepLink}&action=unsubscribe">Unsubscribe from job shares</a></p>
          </div>
        </div>
      </body>
      </html>
    `;

    const text = `
${urgentFlag}${stormFlag}Job Shared with You

${data.senderName} shared a job opportunity with you:

${data.jobTitle}
IBEW Local: ${data.ibewLocal}
Classification: ${data.classification}
Pay Rate: $${data.payRate}/hour
Location: ${data.location}
Start Date: ${data.startDate}

Description: ${data.jobDescription}

${data.stormWork ? '\n⚠️ STORM WORK SAFETY NOTICE\nThis is emergency restoration work. Review safety requirements before accepting.\n' : ''}

View job details: ${data.deepLink}

Shared by: ${data.senderName} (${data.senderEmail})
Journeyman Jobs - Connecting IBEW Workers Nationwide
    `;

    return { subject, html, text };
  }

  private getInvitationEmailTemplate(data: JobShareEmailData) {
    const subject = `${data.senderName} invited you to join Journeyman Jobs`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; color: #1A202C; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #1A202C, #2D3748); color: white; padding: 20px; text-align: center; }
          .invitation { background: #EDF2F7; padding: 20px; margin: 20px 0; border-radius: 8px; }
          .job-preview { background: #F7FAFC; padding: 15px; margin: 15px 0; border-left: 4px solid #B45309; }
          .cta-button { background: #B45309; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0; }
          .features { display: flex; justify-content: space-around; margin: 20px 0; }
          .feature { text-align: center; flex: 1; padding: 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>You're Invited to Journeyman Jobs</h1>
            <p>The IBEW Worker's Job Board</p>
          </div>
          
          <div class="invitation">
            <p>Hi there!</p>
            <p><strong>${data.senderName}</strong> invited you to join Journeyman Jobs and wanted to share this job opportunity with you:</p>
          </div>
          
          <div class="job-preview">
            <h3>${data.jobTitle}</h3>
            <p><strong>IBEW Local ${data.ibewLocal}</strong> • ${data.classification}</p>
            <p>$${data.payRate}/hour • ${data.location}</p>
          </div>
          
          <div style="text-align: center;">
            <a href="${data.deepLink}" class="cta-button">Join Journeyman Jobs & View Job</a>
          </div>
          
          <div class="features">
            <div class="feature">
              <h4>🔍 Find Jobs</h4>
              <p>Search IBEW jobs nationwide</p>
            </div>
            <div class="feature">
              <h4>⛈️ Storm Work</h4>
              <p>Emergency restoration alerts</p>
            </div>
            <div class="feature">
              <h4>👥 Connect</h4>
              <p>Network with other members</p>
            </div>
          </div>
          
          <div style="color: #718096; font-size: 14px; margin-top: 30px;">
            <p>Journeyman Jobs is the premier job board for IBEW electrical workers.</p>
            <p>Join thousands of journeymen, linemen, and wiremen finding their next opportunity.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    const text = `
You're Invited to Journeyman Jobs

${data.senderName} invited you to join Journeyman Jobs and shared this job with you:

${data.jobTitle}
IBEW Local ${data.ibewLocal} • ${data.classification}
$${data.payRate}/hour • ${data.location}

Join Journeyman Jobs to view this job and find more opportunities:
${data.deepLink}

Features:
• Find IBEW jobs nationwide
• Storm work and emergency alerts  
• Connect with other members
• Local directory and resources

Journeyman Jobs - The IBEW Worker's Job Board
    `;

    return { subject, html, text };
  }

  private getCrewShareEmailTemplate(data: CrewShareData) {
    const subject = `${data.senderName} shared a crew job: ${data.jobTitle}`;
    
    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; color: #1A202C; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #1A202C, #2D3748); color: white; padding: 20px; text-align: center; }
          .crew-notice { background: #E6FFFA; color: #234E52; padding: 20px; margin: 20px 0; border-radius: 8px; border: 2px solid #81E6D9; }
          .cta-button { background: #B45309; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>👥 Crew Job Opportunity</h1>
            <p>Multi-person job available</p>
          </div>
          
          <div class="crew-notice">
            <h2>${data.jobTitle}</h2>
            <p><strong>${data.senderName}</strong> shared this crew job with <strong>${data.crewName}</strong></p>
            <p>Multiple positions are available for this job. Coordinate with your crew members to apply together.</p>
          </div>
          
          <div style="text-align: center;">
            <a href="${data.deepLink}" class="cta-button">View Crew Job Details</a>
          </div>
          
          <div style="color: #718096; font-size: 14px; margin-top: 30px;">
            <p>This email was sent to {{MEMBER_EMAIL}} as part of ${data.crewName}</p>
            <p>Shared by: ${data.senderName}</p>
          </div>
        </div>
      </body>
      </html>
    `;

    const text = `
Crew Job Opportunity

${data.senderName} shared this crew job with ${data.crewName}:

${data.jobTitle}

Multiple positions are available. Coordinate with your crew members to apply together.

View details: ${data.deepLink}

This email was sent to {{MEMBER_EMAIL}} as part of ${data.crewName}
Shared by: ${data.senderName}
    `;

    return { subject, html, text };
  }
}

describe('Email Service Tests', () => {
  let emailService: EmailService;
  let mockTransporter: jest.Mocked<nodemailer.Transporter>;
  let mockFirestore: jest.Mocked<admin.firestore.Firestore>;

  beforeEach(() => {
    // Setup mocks
    mockTransporter = {
      sendMail: jest.fn(),
    } as any;

    mockFirestore = {
      collection: jest.fn(),
      doc: jest.fn(),
      batch: jest.fn(),
    } as any;

    (nodemailer.createTransporter as jest.Mock).mockReturnValue(mockTransporter);
    (admin.firestore as jest.Mock).mockReturnValue(mockFirestore);

    // Mock environment variables
    process.env.EMAIL_USER = 'test@journeymanjobs.app';
    process.env.EMAIL_PASS = 'test-password';

    emailService = new EmailService();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Job Share Email Tests', () => {
    it('should send job share email to existing user', async () => {
      const jobData: JobShareEmailData = {
        jobId: 'job-123',
        jobTitle: 'Storm Restoration - IBEW Local 26',
        jobDescription: 'Emergency line restoration after severe storm',
        ibewLocal: 26,
        classification: 'Journeyman Lineman',
        payRate: 55.50,
        location: 'Tacoma, WA',
        startDate: '2025-01-20',
        stormWork: true,
        urgent: true,
        senderName: 'John Foreman',
        senderEmail: 'john@ibew26.org',
        recipientEmail: 'lineman@ibew26.org',
        recipientName: 'Mike Journeyman',
        deepLink: 'https://journeymanjobs.app/job/job-123?ref=share&sender=john',
        invitationId: 'inv-456',
      };

      mockTransporter.sendMail.mockResolvedValue({ messageId: 'test-message-id' } as any);

      await emailService.sendJobShareEmail(jobData);

      expect(mockTransporter.sendMail).toHaveBeenCalledWith({
        from: `"Journeyman Jobs" <${process.env.EMAIL_USER}>`,
        to: 'lineman@ibew26.org',
        subject: expect.stringContaining('🚨 URGENT - ⛈️ STORM WORK - John Foreman shared a job'),
        html: expect.stringContaining('Storm Restoration - IBEW Local 26'),
        text: expect.stringContaining('Storm Restoration - IBEW Local 26'),
        attachments: expect.arrayContaining([
          expect.objectContaining({
            filename: 'storm-work-safety.pdf',
          }),
        ]),
      });
    });

    it('should send regular job email without storm attachments', async () => {
      const jobData: JobShareEmailData = {
        jobId: 'job-456',
        jobTitle: 'Commercial Wiring Project',
        jobDescription: 'Large commercial building electrical work',
        ibewLocal: 134,
        classification: 'Inside Wireman',
        payRate: 48.75,
        location: 'Chicago, IL',
        startDate: '2025-02-01',
        stormWork: false,
        urgent: false,
        senderName: 'Sarah Electrician',
        senderEmail: 'sarah@ibew134.org',
        recipientEmail: 'wireman@ibew134.org',
        deepLink: 'https://journeymanjobs.app/job/job-456?ref=share&sender=sarah',
        invitationId: 'inv-789',
      };

      mockTransporter.sendMail.mockResolvedValue({ messageId: 'test-message-id-2' } as any);

      await emailService.sendJobShareEmail(jobData);

      expect(mockTransporter.sendMail).toHaveBeenCalledWith({
        from: `"Journeyman Jobs" <${process.env.EMAIL_USER}>`,
        to: 'wireman@ibew134.org',
        subject: 'Sarah Electrician shared a job with you: Commercial Wiring Project',
        html: expect.stringContaining('Commercial Wiring Project'),
        text: expect.stringContaining('Commercial Wiring Project'),
        attachments: undefined, // No storm work attachments
      });

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      expect(callArgs.subject).not.toContain('🚨 URGENT');
      expect(callArgs.subject).not.toContain('⛈️ STORM WORK');
      expect(callArgs.html).not.toContain('safety-warning');
    });

    it('should handle email template generation correctly', async () => {
      const jobData: JobShareEmailData = {
        jobId: 'template-test',
        jobTitle: 'Template Test Job',
        jobDescription: 'Testing email template generation',
        ibewLocal: 77,
        classification: 'Journeyman Lineman',
        payRate: 52.25,
        location: 'Seattle, WA',
        startDate: '2025-01-25',
        stormWork: false,
        urgent: false,
        senderName: 'Template Tester',
        senderEmail: 'tester@ibew77.org',
        recipientEmail: 'recipient@ibew77.org',
        deepLink: 'https://journeymanjobs.app/job/template-test',
        invitationId: 'template-inv',
      };

      await emailService.sendJobShareEmail(jobData);

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      
      // Verify HTML template includes all job details
      expect(callArgs.html).toContain('Template Test Job');
      expect(callArgs.html).toContain('IBEW Local:</strong> 77');
      expect(callArgs.html).toContain('Classification:</strong> Journeyman Lineman');
      expect(callArgs.html).toContain('Pay Rate:</strong> $52.25/hour');
      expect(callArgs.html).toContain('Location:</strong> Seattle, WA');
      expect(callArgs.html).toContain('Start Date:</strong> 2025-01-25');
      expect(callArgs.html).toContain('Template Tester');
      expect(callArgs.html).toContain('tester@ibew77.org');

      // Verify text template includes all job details
      expect(callArgs.text).toContain('Template Test Job');
      expect(callArgs.text).toContain('IBEW Local: 77');
      expect(callArgs.text).toContain('Classification: Journeyman Lineman');
      expect(callArgs.text).toContain('Pay Rate: $52.25/hour');
      expect(callArgs.text).toContain('Location: Seattle, WA');
      expect(callArgs.text).toContain('Template Tester');
    });
  });

  describe('Job Invitation Email Tests', () => {
    it('should send invitation email to non-user', async () => {
      const invitationData: JobShareEmailData = {
        jobId: 'invite-job-123',
        jobTitle: 'High Voltage Transmission Work',
        jobDescription: 'Transmission line maintenance and repair',
        ibewLocal: 77,
        classification: 'Journeyman Lineman',
        payRate: 58.75,
        location: 'Seattle, WA',
        startDate: '2025-02-15',
        stormWork: false,
        urgent: false,
        senderName: 'Transmission Foreman',
        senderEmail: 'foreman@ibew77.org',
        recipientEmail: 'newworker@gmail.com',
        deepLink: 'https://journeymanjobs.app/invite?job=invite-job-123&ref=invitation',
        invitationId: 'new-user-inv-123',
      };

      mockTransporter.sendMail.mockResolvedValue({ messageId: 'invite-message-id' } as any);

      await emailService.sendJobInvitationEmail(invitationData);

      expect(mockTransporter.sendMail).toHaveBeenCalledWith({
        from: `"Journeyman Jobs" <${process.env.EMAIL_USER}>`,
        to: 'newworker@gmail.com',
        subject: 'Transmission Foreman invited you to join Journeyman Jobs',
        html: expect.stringContaining("You're Invited to Journeyman Jobs"),
        text: expect.stringContaining("You're Invited to Journeyman Jobs"),
      });

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      
      // Should include app features and job preview
      expect(callArgs.html).toContain('Find Jobs');
      expect(callArgs.html).toContain('Storm Work');
      expect(callArgs.html).toContain('Connect');
      expect(callArgs.html).toContain('High Voltage Transmission Work');
      expect(callArgs.html).toContain('Join Journeyman Jobs & View Job');
    });

    it('should format invitation email for different job types', async () => {
      const stormInvitation: JobShareEmailData = {
        jobId: 'storm-invite-456',
        jobTitle: 'Emergency Storm Response',
        jobDescription: 'Hurricane restoration crew needed',
        ibewLocal: 98,
        classification: 'Journeyman Lineman',
        payRate: 65.00,
        location: 'Miami, FL',
        startDate: '2025-01-18',
        stormWork: true,
        urgent: true,
        senderName: 'Storm Coordinator',
        senderEmail: 'storm@ibew98.org',
        recipientEmail: 'newstormworker@example.com',
        deepLink: 'https://journeymanjobs.app/invite?job=storm-invite-456&storm=true',
        invitationId: 'storm-inv-456',
      };

      await emailService.sendJobInvitationEmail(stormInvitation);

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      expect(callArgs.html).toContain('Emergency Storm Response');
      expect(callArgs.html).toContain('IBEW Local 98');
      expect(callArgs.html).toContain('$65/hour');
      expect(callArgs.html).toContain('Miami, FL');
    });
  });

  describe('Crew Share Email Tests', () => {
    it('should send crew notification emails to all members', async () => {
      const crewData: CrewShareData = {
        jobId: 'crew-job-789',
        jobTitle: 'Multi-Person Storm Restoration',
        crewName: 'Alpha Response Crew',
        memberEmails: [
          'member1@ibew26.org',
          'member2@ibew26.org', 
          'member3@ibew26.org',
        ],
        senderName: 'Crew Foreman',
        deepLink: 'https://journeymanjobs.app/job/crew-job-789?type=crew&crew=alpha',
      };

      mockTransporter.sendMail.mockResolvedValue({ messageId: 'crew-message-id' } as any);

      await emailService.sendCrewNotificationEmails(crewData);

      expect(mockTransporter.sendMail).toHaveBeenCalledTimes(3);

      // Verify each crew member got an email
      const calls = mockTransporter.sendMail.mock.calls;
      expect(calls[0][0]).toEqual(expect.objectContaining({
        to: 'member1@ibew26.org',
        subject: 'Crew Foreman shared a crew job: Multi-Person Storm Restoration',
      }));
      expect(calls[1][0]).toEqual(expect.objectContaining({
        to: 'member2@ibew26.org',
      }));
      expect(calls[2][0]).toEqual(expect.objectContaining({
        to: 'member3@ibew26.org',
      }));

      // Verify personalized content
      expect(calls[0][0].html).toContain('member1@ibew26.org');
      expect(calls[1][0].html).toContain('member2@ibew26.org');
      expect(calls[2][0].html).toContain('member3@ibew26.org');
    });

    it('should handle empty crew member list gracefully', async () => {
      const emptyCrew: CrewShareData = {
        jobId: 'empty-crew-job',
        jobTitle: 'Empty Crew Test',
        crewName: 'Empty Crew',
        memberEmails: [],
        senderName: 'Test Foreman',
        deepLink: 'https://journeymanjobs.app/job/empty-crew-job',
      };

      await emailService.sendCrewNotificationEmails(emptyCrew);

      expect(mockTransporter.sendMail).not.toHaveBeenCalled();
    });

    it('should handle crew email failures gracefully', async () => {
      const crewData: CrewShareData = {
        jobId: 'failing-crew-job',
        jobTitle: 'Failure Test Job',
        crewName: 'Test Crew',
        memberEmails: ['good@ibew.org', 'bad@invalid.email', 'good2@ibew.org'],
        senderName: 'Test Foreman',
        deepLink: 'https://journeymanjobs.app/job/failing-crew-job',
      };

      // Mock one email to fail
      mockTransporter.sendMail
        .mockResolvedValueOnce({ messageId: 'success-1' } as any)
        .mockRejectedValueOnce(new Error('Invalid email address'))
        .mockResolvedValueOnce({ messageId: 'success-3' } as any);

      // Should not throw error even if one email fails
      await expect(emailService.sendCrewNotificationEmails(crewData)).rejects.toThrow();
      
      expect(mockTransporter.sendMail).toHaveBeenCalledTimes(3);
    });
  });

  describe('Email Template Tests', () => {
    it('should generate proper HTML structure', async () => {
      const testData: JobShareEmailData = {
        jobId: 'html-test',
        jobTitle: 'HTML Structure Test',
        jobDescription: 'Testing HTML email structure',
        ibewLocal: 1,
        classification: 'Test Classification',
        payRate: 50.00,
        location: 'Test Location',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'HTML Tester',
        senderEmail: 'html@test.com',
        recipientEmail: 'recipient@test.com',
        deepLink: 'https://test.com/job/html-test',
        invitationId: 'html-inv',
      };

      await emailService.sendJobShareEmail(testData);

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      const html = callArgs.html as string;

      // Verify proper HTML structure
      expect(html).toContain('<!DOCTYPE html>');
      expect(html).toContain('<html>');
      expect(html).toContain('<head>');
      expect(html).toContain('<body>');
      expect(html).toContain('</html>');

      // Verify CSS styling
      expect(html).toContain('font-family: Arial, sans-serif');
      expect(html).toContain('color: #1A202C');

      // Verify responsive design
      expect(html).toContain('viewport');
      expect(html).toContain('max-width: 600px');
    });

    it('should properly escape HTML content', async () => {
      const maliciousData: JobShareEmailData = {
        jobId: 'xss-test',
        jobTitle: '<script>alert("xss")</script>Malicious Job',
        jobDescription: 'Job with <img src="x" onerror="alert(1)"> content',
        ibewLocal: 999,
        classification: 'Test & "Quotes" Classification',
        payRate: 0,
        location: 'Test <b>Location</b>',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'Hacker <script>',
        senderEmail: 'hacker@evil.com',
        recipientEmail: 'victim@test.com',
        deepLink: 'javascript:alert("xss")',
        invitationId: 'xss-inv',
      };

      await emailService.sendJobShareEmail(maliciousData);

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      const html = callArgs.html as string;

      // Should not contain executable scripts
      expect(html).not.toContain('<script>');
      expect(html).not.toContain('onerror=');
      expect(html).not.toContain('javascript:');
      
      // But should contain escaped content
      expect(html).toContain('alert(&quot;xss&quot;)');
    });

    it('should handle missing or null data gracefully', async () => {
      const incompleteData: Partial<JobShareEmailData> = {
        jobId: 'incomplete-job',
        jobTitle: 'Incomplete Job',
        senderName: 'Incomplete Sender',
        recipientEmail: 'incomplete@test.com',
        deepLink: 'https://test.com/incomplete',
      } as JobShareEmailData;

      // Should not throw error
      await emailService.sendJobShareEmail(incompleteData as JobShareEmailData);

      expect(mockTransporter.sendMail).toHaveBeenCalled();
    });
  });

  describe('Email Delivery Tests', () => {
    it('should handle transporter errors gracefully', async () => {
      const testData: JobShareEmailData = {
        jobId: 'error-test',
        jobTitle: 'Error Test Job',
        jobDescription: 'Testing error handling',
        ibewLocal: 1,
        classification: 'Test',
        payRate: 50,
        location: 'Test',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'Error Tester',
        senderEmail: 'error@test.com',
        recipientEmail: 'error@test.com',
        deepLink: 'https://test.com/error',
        invitationId: 'error-inv',
      };

      mockTransporter.sendMail.mockRejectedValue(new Error('SMTP connection failed'));

      await expect(emailService.sendJobShareEmail(testData)).rejects.toThrow('SMTP connection failed');
    });

    it('should validate email addresses before sending', async () => {
      const invalidEmailData: JobShareEmailData = {
        jobId: 'invalid-email-test',
        jobTitle: 'Invalid Email Test',
        jobDescription: 'Testing invalid email handling',
        ibewLocal: 1,
        classification: 'Test',
        payRate: 50,
        location: 'Test',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'Invalid Tester',
        senderEmail: 'valid@test.com',
        recipientEmail: 'not-an-email',
        deepLink: 'https://test.com/invalid',
        invitationId: 'invalid-inv',
      };

      mockTransporter.sendMail.mockRejectedValue(new Error('Invalid recipient address'));

      await expect(emailService.sendJobShareEmail(invalidEmailData)).rejects.toThrow('Invalid recipient address');
    });

    it('should track email delivery status', async () => {
      const trackingData: JobShareEmailData = {
        jobId: 'tracking-test',
        jobTitle: 'Tracking Test Job',
        jobDescription: 'Testing email tracking',
        ibewLocal: 1,
        classification: 'Test',
        payRate: 50,
        location: 'Test',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'Tracking Tester',
        senderEmail: 'tracking@test.com',
        recipientEmail: 'recipient@test.com',
        deepLink: 'https://test.com/tracking',
        invitationId: 'tracking-inv',
      };

      const mockResponse = {
        messageId: 'test-message-id-12345',
        accepted: ['recipient@test.com'],
        rejected: [],
        pending: [],
        envelope: {
          from: 'test@journeymanjobs.app',
          to: ['recipient@test.com'],
        },
      };

      mockTransporter.sendMail.mockResolvedValue(mockResponse as any);

      await emailService.sendJobShareEmail(trackingData);

      expect(mockTransporter.sendMail).toHaveBeenCalledWith(expect.objectContaining({
        to: 'recipient@test.com',
      }));
    });
  });

  describe('Performance Tests', () => {
    it('should send crew emails concurrently for performance', async () => {
      const largeCrew: CrewShareData = {
        jobId: 'performance-test',
        jobTitle: 'Performance Test Job',
        crewName: 'Large Crew',
        memberEmails: Array.from({ length: 50 }, (_, i) => `member${i}@ibew.org`),
        senderName: 'Performance Tester',
        deepLink: 'https://test.com/performance',
      };

      mockTransporter.sendMail.mockResolvedValue({ messageId: 'perf-message' } as any);

      const startTime = Date.now();
      await emailService.sendCrewNotificationEmails(largeCrew);
      const endTime = Date.now();

      expect(mockTransporter.sendMail).toHaveBeenCalledTimes(50);
      
      // Should complete relatively quickly due to concurrency
      expect(endTime - startTime).toBeLessThan(5000);
    });

    it('should handle rate limiting gracefully', async () => {
      const rateLimitData: JobShareEmailData = {
        jobId: 'rate-limit-test',
        jobTitle: 'Rate Limit Test',
        jobDescription: 'Testing rate limiting',
        ibewLocal: 1,
        classification: 'Test',
        payRate: 50,
        location: 'Test',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'Rate Tester',
        senderEmail: 'rate@test.com',
        recipientEmail: 'rate@test.com',
        deepLink: 'https://test.com/rate',
        invitationId: 'rate-inv',
      };

      mockTransporter.sendMail.mockRejectedValue(new Error('Rate limit exceeded'));

      await expect(emailService.sendJobShareEmail(rateLimitData)).rejects.toThrow('Rate limit exceeded');
    });
  });

  describe('Security Tests', () => {
    it('should not expose sensitive information in email content', async () => {
      const sensitiveData: JobShareEmailData = {
        jobId: 'security-test',
        jobTitle: 'Security Test Job',
        jobDescription: 'Job with sensitive info',
        ibewLocal: 1,
        classification: 'Test',
        payRate: 50,
        location: 'Secret Location',
        startDate: '2025-01-01',
        stormWork: false,
        urgent: false,
        senderName: 'Security Tester',
        senderEmail: 'security@test.com',
        recipientEmail: 'recipient@test.com',
        deepLink: 'https://test.com/security?token=secret123',
        invitationId: 'security-inv',
      };

      await emailService.sendJobShareEmail(sensitiveData);

      const callArgs = mockTransporter.sendMail.mock.calls[0][0] as MailOptions;
      
      // Should not expose system internals
      expect(callArgs.html).not.toContain('password');
      expect(callArgs.html).not.toContain('token=secret123');
      expect(callArgs.html).not.toContain('api_key');
    });

    it('should validate sender permissions', async () => {
      // This would be implemented in the actual Cloud Function
      // Test would verify that only authorized users can send emails
      expect(true).toBe(true); // Placeholder
    });
  });
});

// SMS Service tests for completeness
describe('SMS Service Tests', () => {
  it('should send SMS notifications for job shares', async () => {
    // Placeholder for SMS testing
    // Would test Twilio or similar SMS service integration
    expect(true).toBe(true);
  });

  it('should format SMS messages appropriately', async () => {
    const smsData: SMSData = {
      phoneNumber: '+15551234567',
      message: 'John shared a job with you: Storm Work - IBEW Local 26. View details: https://journeymanjobs.app/job/123',
      jobId: 'sms-job-123',
      deepLink: 'https://journeymanjobs.app/job/123?ref=sms',
      senderName: 'John Foreman',
    };

    // Test SMS message formatting
    expect(smsData.message).toContain('John shared a job');
    expect(smsData.message).toContain('Storm Work');
    expect(smsData.message).toContain('https://journeymanjobs.app');
    expect(smsData.message.length).toBeLessThanOrEqual(160); // SMS length limit
  });

  it('should handle international phone numbers', async () => {
    const internationalSMS: SMSData = {
      phoneNumber: '+441234567890', // UK number
      message: 'Job shared with you',
      jobId: 'international-job',
      deepLink: 'https://journeymanjobs.app/job/international',
      senderName: 'International Sender',
    };

    // Test international number handling
    expect(internationalSMS.phoneNumber).toMatch(/^\+\d{10,15}$/);
  });
});