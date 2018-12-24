import React from 'react';
import styled from 'styled-components/macro';
import { reduxForm } from 'redux-form';
import Form from './Form';
import Input from './Input';
import SubmitButton from './SubmitButton';

const StyledForm = styled(Form)`
  padding: 0;
  border: 1px solid #eee;
  flex: 2;
`;

const TextArea = styled(Input)`
  margin-bottom: 0;
`;

const StyledSubmitButton = styled(SubmitButton)`
  padding: 4px 8px;
  margin: 4px 3px 3px;
  font-size: 13px;
`;

const CommentForm = () => (
  <StyledForm>
    <TextArea
      name='comment'
      component='textarea'
      rows='3'
      placeholder='enter your comment'
    />
    <StyledSubmitButton type='submit'>submit</StyledSubmitButton>
  </StyledForm>
);

export default reduxForm({ form: 'comment' })(CommentForm);
